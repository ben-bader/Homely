package com.homely.auth.service;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.homely.auth.dto.AuthResponse;
import com.homely.auth.dto.LoginRequest;
import com.homely.auth.dto.LogoutRequest;
import com.homely.auth.dto.RefreshTokenRequest;
import com.homely.auth.dto.RegisterRequest;
import com.homely.auth.entity.RefreshToken;
import com.homely.common.exception.UserNotFoundException;
import com.homely.common.service.EmailService;
import com.homely.config.AppConfig;
import com.homely.moderation.entity.LogActivity;
import com.homely.moderation.service.LogActivityService;
import com.homely.user.entity.Profile;
import com.homely.user.entity.User;
import com.homely.user.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AuthService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final TokenBlacklist tokenBlacklist;
    private final RefreshTokenService refreshTokenService;
    private final EmailService emailService;
    private final AppConfig appConfig;
    private final LogActivityService logActivityService;

    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    public AuthResponse register(RegisterRequest request, String deviceInfo) {
        String normalizedEmail = request.getEmail().trim().toLowerCase();
        if (userRepository.existsByEmailIgnoreCase(normalizedEmail)) {
            throw new IllegalArgumentException("Email already exists");
        }

        User user = new User();
        user.setEmail(normalizedEmail);
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setName(request.getName());
        user.setPhone(request.getPhone());
        user.setRole(request.getRole());
        user.setEmailVerified(false);
        user.setVerificationToken(UUID.randomUUID().toString());

        Profile profile = new Profile();
        profile.setUser(user);
        user.setProfile(profile);

        User savedUser = userRepository.save(user);

        logActivityService.log(
                savedUser,
                LogActivity.ActivityType.SIGNUP,
                LogActivity.EntityType.USER,
                savedUser.getId(),
                "User registered with email: " + normalizedEmail + " and role: " + request.getRole(),
                "{\"email\":\"" + normalizedEmail + "\",\"role\":\"" + request.getRole() + "\"}"
        );

        String verificationLink = appConfig.getBackendUrl() + "/api/auth/verify-email?token=" + savedUser.getVerificationToken();
        emailService.sendVerificationEmail(savedUser.getEmail(), verificationLink);

        return buildAuthResponse(savedUser, refreshTokenService.createToken(savedUser, deviceInfo));
    }

    public AuthResponse login(LoginRequest request, String deviceInfo) {
        String normalizedEmail = request.getEmail().trim().toLowerCase();
        User user = userRepository.findByEmailIgnoreCase(normalizedEmail)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new IllegalArgumentException("Invalid credentials");
        }
        if (!user.isActive()) {
            throw new IllegalStateException("User account is deactivated");
        }
        if (!user.isEmailVerified()) {
            throw new IllegalStateException("Please verify your email first");
        }

        logActivityService.log(
                user,
                LogActivity.ActivityType.LOGIN,
                LogActivity.EntityType.USER,
                user.getId(),
                "User logged in with email: " + normalizedEmail,
                "{\"email\":\"" + normalizedEmail + "\"}"
        );

        return buildAuthResponse(user, refreshTokenService.createToken(user, deviceInfo));
    }

    @Transactional
    public AuthResponse refreshToken(RefreshTokenRequest request, String deviceInfo) {
        if (request == null || request.getRefreshToken() == null || request.getRefreshToken().isBlank()) {
            throw new IllegalArgumentException("Refresh token is required");
        }
        RefreshToken token = refreshTokenService.findByToken(request.getRefreshToken())
                .orElseThrow(() -> new IllegalArgumentException("Refresh token not found"));

        if (token.getRevoked()) {
            throw new IllegalStateException("Refresh token revoked");
        }
        if (refreshTokenService.isExpired(token)) {
            throw new IllegalStateException("Refresh token expired");
        }

        RefreshToken newRefreshToken = refreshTokenService.rotateToken(token, deviceInfo);
        return buildAuthResponse(token.getUser(), newRefreshToken);
    }

    public void logout(LogoutRequest request, String accessToken) {
        if (request != null && request.getRefreshToken() != null) {
            refreshTokenService.findByToken(request.getRefreshToken())
                    .ifPresent(refreshTokenService::revoke);
        }
        if (accessToken != null && accessToken.startsWith("Bearer ")) {
            accessToken = accessToken.substring(7);
        }
        if (accessToken != null && !accessToken.isBlank()) {
            tokenBlacklist.blacklistToken(accessToken, jwtService.extractExpiration(accessToken));
        }
    }

    public void verifyEmail(String token) {
        User user = userRepository.findByVerificationToken(token)
                .orElseThrow(() -> new RuntimeException("Invalid verification token"));
        user.setEmailVerified(true);
        user.setVerificationToken(null);
        userRepository.save(user);
    }

    public void requestPasswordReset(String email) {
        String normalizedEmail = email.trim().toLowerCase();
        User user = userRepository.findByEmailIgnoreCase(normalizedEmail)
                .orElseThrow(() -> new UserNotFoundException(normalizedEmail));

        // Generate 6-digit OTP code
        String resetCode = generateOtpCode();
        user.setResetCode(resetCode);
        user.setResetCodeExpiry(Instant.now().plusSeconds(900)); // 15 minutes
        userRepository.save(user);

        logActivityService.log(
                user,
                LogActivity.ActivityType.PASSWORD_RESET_REQUESTED,
                LogActivity.EntityType.USER,
                user.getId(),
                "Password reset requested for email: " + normalizedEmail,
                "{\"email\":\"" + normalizedEmail + "\"}"
        );

        // Send OTP via email
        emailService.sendPasswordResetCodeEmail(user.getEmail(), resetCode, 15);
    }

    public void resetPassword(String email, String code, String newPassword) {
        String normalizedEmail = email.trim().toLowerCase();
        
        // Validate inputs
        if (email == null || email.isBlank()) {
            throw new IllegalArgumentException("Email is required");
        }
        if (code == null || !code.matches("^[0-9]{6}$")) {
            throw new IllegalArgumentException("Invalid reset code format");
        }
        if (newPassword == null || newPassword.isBlank()) {
            throw new IllegalArgumentException("New password is required");
        }

        User user = userRepository.findByResetCodeAndEmailIgnoreCase(code, normalizedEmail)
                .orElseThrow(() -> new IllegalArgumentException("Invalid email or reset code"));

        // Validate OTP expiration
        if (user.getResetCodeExpiry() == null || user.getResetCodeExpiry().isBefore(Instant.now())) {
            throw new IllegalStateException("Reset code has expired. Please request a new one.");
        }

        // Update password
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        user.setResetCode(null);
        user.setResetCodeExpiry(null);
        userRepository.save(user);

        logActivityService.log(
                user,
                LogActivity.ActivityType.PASSWORD_RESET_COMPLETED,
                LogActivity.EntityType.USER,
                user.getId(),
                "Password reset completed for email: " + normalizedEmail,
                "{\"email\":\"" + normalizedEmail + "\"}"
        );
    }

    /**
     * Generate a 6-digit OTP code
     */
    private String generateOtpCode() {
        int code = SECURE_RANDOM.nextInt(1_000_000);
        return String.format("%06d", code);
    }

        private AuthResponse buildAuthResponse(User user, RefreshToken refreshToken) {
        var roles = user.getAuthorities().stream()
            .map(grantedAuthority -> grantedAuthority.getAuthority())
            .collect(Collectors.toList());

        String accessToken = jwtService.generateToken(user);
        long expiresInSeconds = jwtService.getJwtExpirationMillis() / 1000;

        return new AuthResponse(
            accessToken,
            refreshToken.getToken(),
            "Bearer",
            expiresInSeconds,
            user.getUsername(),
            roles
        );
        }
}
