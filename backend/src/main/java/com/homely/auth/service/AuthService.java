package com.homely.auth.service;

import java.util.UUID;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.homely.auth.dto.AuthResponse;
import com.homely.auth.dto.LoginRequest;
import com.homely.auth.dto.RegisterRequest;
import com.homely.common.service.EmailService;
import com.homely.config.AppConfig;
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
    private final EmailService emailService;
    private final AppConfig appConfig;

    public AuthResponse register(RegisterRequest request){
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already exists");
        }
        User user = new User();
        user.setEmail(request.getEmail());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setName(request.getName());
        user.setPhone(request.getPhone());
        user.setRole(request.getRole());
        user.setEmailVerified(false);
        user.setVerificationToken(UUID.randomUUID().toString());

        // Create profile automatically
        Profile profile = new Profile();
        profile.setUser(user);
        user.setProfile(profile);

        User savedUser = userRepository.save(user);

        // Send verification email
        String verificationLink = appConfig.getFrontendUrl() + "/api/auth/verify-email?token=" + user.getVerificationToken();
        emailService.sendEmail(user.getEmail(), "Verify Your Email", "Please click the link to verify your email: " + verificationLink);

        return new AuthResponse(jwtService.generateToken(savedUser));
    }

    public AuthResponse login(LoginRequest request){
        User user = userRepository.findByEmail(request.getEmail())
                    .orElseThrow(()-> new RuntimeException("User not found"));
        if(!passwordEncoder.matches(request.getPassword(), user.getPasswordHash()))   {
            throw  new RuntimeException("Invalid credentials");
        }
        if (!user.isActive()) {
            throw new RuntimeException("User account is deactivated");
        }
        if (!user.isEmailVerified()) {
            throw new RuntimeException("Please verify your email first");
        }

        return new AuthResponse(jwtService.generateToken(user));
    }

    public void logout(String token) {
        if (token == null) return;
        if (token.startsWith("Bearer ")) token = token.substring(7);
        java.util.Date expiry = jwtService.extractExpiration(token);
        tokenBlacklist.blacklistToken(token, expiry);
    }

    public void verifyEmail(String token) {
        User user = userRepository.findByVerificationToken(token)
                .orElseThrow(() -> new RuntimeException("Invalid verification token"));
        user.setEmailVerified(true);
        user.setVerificationToken(null);
        userRepository.save(user);
    }

    public void requestPasswordReset(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        user.setResetToken(UUID.randomUUID().toString());
        user.setResetTokenExpiry(java.time.Instant.now().plusSeconds(3600)); // 1 hour expiry
        userRepository.save(user);

        String resetLink = appConfig.getFrontendUrl() + "/api/auth/reset-password?token=" + user.getResetToken();
        emailService.sendEmail(user.getEmail(), "Reset Your Password", "Please click the link to reset your password: " + resetLink);
    }

    public void resetPassword(String token, String newPassword) {
        User user = userRepository.findByResetToken(token)
                .orElseThrow(() -> new RuntimeException("Invalid reset token"));
        if (user.getResetTokenExpiry().isBefore(java.time.Instant.now())) {
            throw new RuntimeException("Reset token has expired");
        }
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        user.setResetToken(null);
        user.setResetTokenExpiry(null);
        userRepository.save(user);
    }
}
