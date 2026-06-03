package com.homely.auth.controller;

import java.util.List;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.homely.auth.dto.ApiResponse;
import com.homely.auth.dto.AuthResponse;
import com.homely.auth.dto.LoginRequest;
import com.homely.auth.dto.LogoutRequest;
import com.homely.auth.dto.MeDto;
import com.homely.auth.dto.PasswordResetCodeRequest;
import com.homely.auth.dto.PasswordResetConfirmRequest;
import com.homely.auth.dto.RefreshTokenRequest;
import com.homely.auth.dto.RegisterRequest;
import com.homely.auth.service.AuthService;
import com.homely.common.exception.UserNotFoundException;
import com.homely.user.entity.User;
import com.homely.user.repository.UserRepository;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {
    private final AuthService authService;
    private final UserRepository userRepository;
    private static final Logger log = LoggerFactory.getLogger(AuthController.class);

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponse>> register(
            @Valid @RequestBody RegisterRequest request,
            HttpServletRequest servletRequest
    ) {
        try {
            AuthResponse response = authService.register(request, extractDeviceInfo(servletRequest));
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(ApiResponse.success("Registration successful", response));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            log.error("Registration failed", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Registration failed. Please try again."));
        }
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<MeDto>> me() {
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            if (auth == null || auth.getName() == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(ApiResponse.error("Not authenticated"));
            }

            User user = userRepository.findByEmail(auth.getName())
                    .orElseThrow(() -> new RuntimeException("User not found"));

            List<String> roles = auth.getAuthorities().stream()
                    .map(GrantedAuthority::getAuthority)
                    .collect(Collectors.toList());

            MeDto meDto = new MeDto(user.getId(), user.getEmail(), roles);
            return ResponseEntity.ok(ApiResponse.success("User retrieved", meDto));
        } catch (Exception e) {
            log.error("Failed to retrieve user info", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to retrieve user info"));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(
            @Valid @RequestBody LoginRequest request,
            HttpServletRequest servletRequest
    ) {
        try {
            AuthResponse response = authService.login(request, extractDeviceInfo(servletRequest));
            return ResponseEntity.ok(ApiResponse.success("Login successful", response));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            log.error("Login failed", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Login failed. Please try again."));
        }
    }

    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<AuthResponse>> refresh(
            @RequestBody RefreshTokenRequest request,
            HttpServletRequest servletRequest
    ) {
        try {
            AuthResponse response = authService.refreshToken(request, extractDeviceInfo(servletRequest));
            return ResponseEntity.ok(ApiResponse.success("Token refreshed", response));
        } catch (IllegalArgumentException | IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            log.error("Token refresh failed", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Token refresh failed"));
        }
    }

    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout(
            @RequestBody(required = false) LogoutRequest request,
            @RequestHeader(value = "Authorization", required = false) String authHeader
    ) {
        try {
            authService.logout(request, authHeader);
            return ResponseEntity.ok(ApiResponse.success("Logout successful"));
        } catch (Exception e) {
            log.error("Logout failed", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Logout failed"));
        }
    }

    private String extractDeviceInfo(HttpServletRequest request) {
        var userAgent = request.getHeader("User-Agent");
        var ipAddress = request.getHeader("X-Forwarded-For");
        if (ipAddress == null || ipAddress.isBlank()) {
            ipAddress = request.getRemoteAddr();
        }
        return "ua=" + (userAgent == null ? "unknown" : userAgent)
                + ";ip=" + (ipAddress == null ? "unknown" : ipAddress);
    }

    @GetMapping("/verify-email")
    public ResponseEntity<?> verifyEmail(
            @RequestParam String token,
            @RequestHeader(value = "Accept", required = false) String acceptHeader) {
        log.info("Incoming verify-email request with token={}", token);
        try {
            authService.verifyEmail(token);
            if (acceptHeader != null && acceptHeader.contains("application/json")) {
                return ResponseEntity.ok(ApiResponse.success("Email verified successfully"));
            }
            // Return HTML for browser requests
            String html = "<!DOCTYPE html><html><head><meta charset='UTF-8'><title>Email Verified</title>"
                    + "<style>body{font-family:Arial,sans-serif;display:flex;justify-content:center;align-items:center;height:100vh;margin:0;background:#f5f5f5;}"
                    + ".container{background:white;padding:40px;border-radius:8px;box-shadow:0 2px 10px rgba(0,0,0,0.1);text-align:center;}"
                    + "h1{color:#4CAF50;margin:0 0 10px;}p{color:#666;margin:10px 0;}"
                    + "a{display:inline-block;margin-top:20px;padding:10px 20px;background:#4CAF50;color:white;text-decoration:none;border-radius:4px;}</style>"
                    + "</head><body><div class='container'><h1>✓ Email Verified!</h1>"
                    + "<p>Your email has been verified successfully.</p>"
                    + "<p>You can now log in to your account.</p>"
                    + "<a href='https://elegant-jasiah-speedfully.ngrok-free.dev'>Go to App</a>"
                    + "</div></body></html>";
            return ResponseEntity.ok()
                    .contentType(MediaType.TEXT_HTML)
                    .body(html);
        } catch (Exception e) {
            log.error("Email verification failed for token={}: {}", token, e.getMessage());
            if (acceptHeader != null && acceptHeader.contains("application/json")) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(ApiResponse.error("Email verification failed"));
            }
            // Return HTML for browser requests
            String html = "<!DOCTYPE html><html><head><meta charset='UTF-8'><title>Verification Failed</title>"
                    + "<style>body{font-family:Arial,sans-serif;display:flex;justify-content:center;align-items:center;height:100vh;margin:0;background:#f5f5f5;}"
                    + ".container{background:white;padding:40px;border-radius:8px;box-shadow:0 2px 10px rgba(0,0,0,0.1);text-align:center;}"
                    + "h1{color:#f44336;margin:0 0 10px;}p{color:#666;margin:10px 0;}"
                    + "a{display:inline-block;margin-top:20px;padding:10px 20px;background:#2196F3;color:white;text-decoration:none;border-radius:4px;}</style>"
                    + "</head><body><div class='container'><h1>✗ Verification Failed</h1>"
                    + "<p>The verification link is invalid or expired.</p>"
                    + "<p>Please request a new verification email.</p>"
                    + "<a href='https://elegant-jasiah-speedfully.ngrok-free.dev'>Go to App</a>"
                    + "</div></body></html>";
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .contentType(MediaType.TEXT_HTML)
                    .body(html);
        }
    }

    @PostMapping("/request-password-reset")
    public ResponseEntity<ApiResponse<Void>> requestPasswordReset(
            @Valid @RequestBody PasswordResetCodeRequest request) {
        try {
            authService.requestPasswordReset(request.getEmail());
            return ResponseEntity.ok(ApiResponse.success("Password reset code sent to your email. Code expires in 15 minutes."));
        } catch (UserNotFoundException e) {
            log.warn("Password reset requested for unknown email: {}", request.getEmail());
            // Avoid exposing whether the email exists for security and UX reasons.
            return ResponseEntity.ok(ApiResponse.success("If an account with that email exists, a reset code has been sent."));
        } catch (Exception e) {
            log.error("Password reset request failed", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to process password reset request"));
        }
    }

    @PostMapping("/reset-password")
    public ResponseEntity<ApiResponse<Void>> resetPassword(
            @Valid @RequestBody PasswordResetConfirmRequest request) {
        try {
            authService.resetPassword(request.getEmail(), request.getCode(), request.getNewPassword());
            return ResponseEntity.ok(ApiResponse.success("Password reset successfully"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error(e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            log.error("Password reset failed", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Password reset failed"));
        }
    }

}
