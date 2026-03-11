package com.homely.auth.controller;

import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.homely.auth.dto.AuthResponse;
import com.homely.auth.dto.LoginRequest;
import com.homely.auth.dto.RegisterRequest;
import com.homely.auth.service.AuthService;
import com.homely.user.entity.User;
import com.homely.user.repository.UserRepository;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;


@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {
    private final AuthService authService;
    private final UserRepository userRepository;

    @PostMapping("/register")
    public AuthResponse register(@Valid @RequestBody RegisterRequest request) {
        return authService.register(request);
    }

    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest request) {
        return authService.login(request);
    }
    
    @PostMapping("/logout")
    public void logout(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        authService.logout(authHeader);
    }

    @GetMapping(value = "/verify-email", produces = MediaType.TEXT_HTML_VALUE)
    public String verifyEmail(@RequestParam String token) {
        try {
            authService.verifyEmail(token);
            return """
                <!DOCTYPE html>
                <html lang="en">
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Email Verified - Homely</title>
                    <style>
                        body {
                            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                            margin: 0;
                            padding: 0;
                            min-height: 100vh;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                        }
                        .container {
                            background: white;
                            border-radius: 12px;
                            padding: 2rem;
                            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
                            text-align: center;
                            max-width: 400px;
                            width: 90%;
                        }
                        .success-icon {
                            width: 64px;
                            height: 64px;
                            background: #10b981;
                            border-radius: 50%;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            margin: 0 auto 1.5rem;
                            font-size: 28px;
                        }
                        h1 {
                            color: #1f2937;
                            margin-bottom: 0.5rem;
                            font-size: 1.875rem;
                            font-weight: 700;
                        }
                        p {
                            color: #6b7280;
                            margin-bottom: 2rem;
                            line-height: 1.6;
                        }
                        .btn {
                            background: #3b82f6;
                            color: white;
                            border: none;
                            padding: 0.75rem 2rem;
                            border-radius: 8px;
                            font-weight: 600;
                            text-decoration: none;
                            display: inline-block;
                            transition: background-color 0.2s;
                        }
                        .btn:hover {
                            background: #2563eb;
                        }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="success-icon">✓</div>
                        <h1>Email Verified Successfully!</h1>
                        <p>Your email has been verified. You can now log in to your account.</p>
                        <a href="/" class="btn">Go to Login</a>
                    </div>
                </body>
                </html>
                """;
        } catch (Exception e) {
            return """
                <!DOCTYPE html>
                <html lang="en">
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Verification Failed - Homely</title>
                    <style>
                        body {
                            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                            margin: 0;
                            padding: 0;
                            min-height: 100vh;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                        }
                        .container {
                            background: white;
                            border-radius: 12px;
                            padding: 2rem;
                            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
                            text-align: center;
                            max-width: 400px;
                            width: 90%;
                        }
                        .error-icon {
                            width: 64px;
                            height: 64px;
                            background: #ef4444;
                            border-radius: 50%;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            margin: 0 auto 1.5rem;
                            font-size: 28px;
                            color: white;
                        }
                        h1 {
                            color: #1f2937;
                            margin-bottom: 0.5rem;
                            font-size: 1.875rem;
                            font-weight: 700;
                        }
                        p {
                            color: #6b7280;
                            margin-bottom: 2rem;
                            line-height: 1.6;
                        }
                        .btn {
                            background: #3b82f6;
                            color: white;
                            border: none;
                            padding: 0.75rem 2rem;
                            border-radius: 8px;
                            font-weight: 600;
                            text-decoration: none;
                            display: inline-block;
                            transition: background-color 0.2s;
                        }
                        .btn:hover {
                            background: #2563eb;
                        }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="error-icon">✕</div>
                        <h1>Verification Failed</h1>
                        <p>The verification link is invalid or has expired. Please try registering again or contact support.</p>
                        <a href="/" class="btn">Go to Home</a>
                    </div>
                </body>
                </html>
                """;
        }
    }

    @PostMapping("/request-password-reset")
    public String requestPasswordReset(@RequestBody com.homely.auth.dto.PasswordResetRequest request) {
        authService.requestPasswordReset(request.getEmail());
        return "Password reset email sent";
    }

    @GetMapping(value = "/reset-password", produces = MediaType.TEXT_HTML_VALUE)
    public String showResetPasswordForm(@RequestParam String token) {
        // Validate token first
        try {
            User user = userRepository.findByResetToken(token)
                    .orElseThrow(() -> new RuntimeException("Invalid reset token"));
            if (user.getResetTokenExpiry().isBefore(java.time.Instant.now())) {
                throw new RuntimeException("Reset token has expired");
            }
        } catch (Exception e) {
            return "<!DOCTYPE html><html><head><title>Invalid Link</title></head><body><h1>Invalid Reset Link</h1><p>The password reset link is invalid or has expired.</p><a href='/'>Go to Home</a></body></html>";
        }

        return "<!DOCTYPE html><html><head><title>Reset Password</title><style>body{font-family:Arial,sans-serif;margin:40px;text-align:center;}form{max-width:300px;margin:0 auto;}input{display:block;width:100%;margin:10px 0;padding:8px;}button{background:#007bff;color:white;border:none;padding:10px;width:100%;cursor:pointer;}button:hover{background:#0056b3;}</style></head><body><h1>Reset Your Password</h1><form action='/api/auth/reset-password' method='post'><input type='hidden' name='token' value='" + token + "'><input type='password' name='newPassword' placeholder='New Password' required minlength='6'><button type='submit'>Reset Password</button></form></body></html>";
    }

    @PostMapping("/reset-password")
    public String resetPassword(@RequestParam String token, @RequestParam String newPassword) {
        authService.resetPassword(token, newPassword);
        return "Password reset successfully";
    }
    
}
