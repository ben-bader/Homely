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
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: #070711;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 2rem;
    }
    .container {
      background: #0e0c1f;
      border: 0.5px solid #2a2550;
      border-radius: 16px;
      padding: 2.5rem 2rem;
      text-align: center;
      max-width: 400px;
      width: 100%;
    }
    .success-icon {
      width: 72px; height: 72px;
      border-radius: 50%;
      background: rgba(34,197,94,0.12);
      border: 1px solid rgba(34,197,94,0.25);
      display: flex; align-items: center; justify-content: center;
      margin: 0 auto 1.75rem;
    }
    h1 {
      color: #f1f0ff;
      font-size: 22px;
      font-weight: 500;
      margin-bottom: 0.5rem;
    }
    p {
      color: #8b87a8;
      font-size: 14px;
      line-height: 1.7;
      margin-bottom: 2rem;
    }

    .footer-text {
      margin: 1.25rem 0 0;
      font-size: 13px;
      color: #4d4870;
    }
    .footer-text a { color: #7c6ddb; text-decoration: none; }
  </style>
</head>
<body>
  <div class="container">
    <div class="success-icon">
      <svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#22c55e" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <polyline points="20 6 9 17 4 12"/>
      </svg>
    </div>
    <h1>Email verified!</h1>
    <p>Your email has been verified successfully. You can now close this tab and log in to your account.</p>
    <p class="footer-text">Need help? <a href="mailto:homely.support@gmail.com">Contact support</a></p>
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
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: #070711;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 2rem;
    }
    .container {
      background: #0e0c1f;
      border: 0.5px solid #2a2550;
      border-radius: 16px;
      padding: 2.5rem 2rem;
      text-align: center;
      max-width: 400px;
      width: 100%;
    }
    .error-icon {
      width: 72px; height: 72px;
      border-radius: 50%;
      background: rgba(224,80,80,0.12);
      border: 1px solid rgba(224,80,80,0.25);
      display: flex; align-items: center; justify-content: center;
      margin: 0 auto 1.75rem;
    }
    h1 {
      color: #f1f0ff;
      font-size: 22px;
      font-weight: 500;
      margin-bottom: 0.5rem;
    }
    p {
      color: #8b87a8;
      font-size: 14px;
      line-height: 1.7;
      margin-bottom: 2rem;
    }
    .email-link {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      background: #16123a;
      border: 0.5px solid #2a2550;
      border-radius: 8px;
      padding: 9px 16px;
      color: #a09cc4;
      font-size: 13px;
      text-decoration: none;
      margin-bottom: 1rem;
    }

    
  </style>
</head>
<body>
  <div class="container">
    <div class="error-icon">
      <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#e05050" stroke-width="2.5" stroke-linecap="round">
        <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
      </svg>
    </div>
    <h1>Verification failed</h1>
    <p>The verification link is invalid or has expired. Please try registering again or reach out to support.</p>
    <a class="email-link" href="mailto:homely.support@gmail.com">
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
      homely.support@gmail.com
    </a>
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
        return """
        <!DOCTYPE html>
                <html>
                <head>
                  <meta charset="UTF-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <title>Reset Password</title>
                  <style>
                    * { margin: 0; padding: 0; box-sizing: border-box; }
                    body {
                      font-family: Arial, sans-serif;
                      background: #070711;
                      display: flex;
                      flex-direction: column;
                      align-items: center;
                      justify-content: center;
                      min-height: 100vh;
                      padding: 2rem;
                    }
                    .icon-wrap {
                      width: 48px; height: 48px;
                      background: linear-gradient(135deg, #4f46e5, #7c3aed);
                      border-radius: 12px;
                      display: flex; align-items: center; justify-content: center;
                      margin: 0 auto 1rem;
                      box-shadow: 0 0 24px rgba(124,58,237,0.3);
                    }
                    .header { text-align: center; margin-bottom: 2rem; }
                    .header h1 { color: #f1f0ff; font-size: 22px; font-weight: 500; margin-bottom: 4px; }
                    .header p { color: #8b87a8; font-size: 14px; }
                    form {
                      background: #0e0c1f;
                      border: 0.5px solid #2a2550;
                      border-radius: 16px;
                      padding: 2rem;
                      width: 100%; max-width: 380px;
                      display: flex; flex-direction: column; gap: 0;
                    }
                    .field { margin-bottom: 1.25rem; }
                    .field label { display: block; font-size: 13px; font-weight: 500; color: #a09cc4; margin-bottom: 6px; }
                    .input-wrap { position: relative; }
                    input[type="password"], input[type="text"] {
                      width: 100%;
                      padding: 10px 40px 10px 12px;
                      background: #16123a;
                      border: 1px solid #2a2550;
                      border-radius: 8px;
                      color: #e8e6ff;
                      font-size: 14px;
                      outline: none;
                      transition: border-color 0.2s;
                    }
                    input:focus { border-color: #6d5cde; }
                    .toggle-btn {
                      position: absolute; right: 10px; top: 50%; transform: translateY(-50%);
                      background: none; border: none; cursor: pointer; padding: 0; color: #8b87a8;
                    }
                    .strength-bar { margin-top: 6px; height: 3px; border-radius: 2px; background: #1e1a40; overflow: hidden; display: none; }
                    .strength-fill { height: 100%; width: 0; border-radius: 2px; transition: width 0.3s, background 0.3s; }
                    .strength-label { font-size: 11px; color: #8b87a8; margin: 4px 0 0; display: none; }
                    .match-msg { font-size: 12px; margin: 6px 0 0; min-height: 16px; }
                    button[type="submit"] {
                      width: 100%; padding: 11px;
                      border-radius: 8px; border: none;
                      background: #2a2550; color: #6b669e;
                      font-size: 15px; font-weight: 500;
                      cursor: not-allowed;
                      transition: background 0.2s, color 0.2s, box-shadow 0.2s;
                      margin-top: 0.25rem;
                    }
                    button[type="submit"].active {
                      background: linear-gradient(135deg, #4f46e5, #7c3aed);
                      color: #fff; cursor: pointer;
                      box-shadow: 0 0 16px rgba(124,58,237,0.3);
                    }
                    .footer-text { color: #4d4870; font-size: 13px; margin-top: 1.5rem; }
                    .footer-text a { color: #7c6ddb; text-decoration: none; }
                  </style>
                </head>
                <body>
                  <div class="header">

                    <h1>Reset your password</h1>
                    <p>Choose a strong new password</p>
                  </div>

                  <form action="/api/auth/reset-password" method="post" onsubmit="return validateForm()">
                    <input type="hidden" name="token" value="' + token + '">

                    <div class="field">
                      <label>New password</label>
                      <div class="input-wrap">
                        <input type="password" id="newPassword" name="newPassword" placeholder="Min. 6 characters" required minlength="6" oninput="validate()">
                        <button type="button" class="toggle-btn" onclick="togglePw('newPassword')">👁</button>
                      </div>
                      <div class="strength-bar" id="strengthBar"><div class="strength-fill" id="strengthFill"></div></div>
                      <p class="strength-label" id="strengthLabel"></p>
                    </div>

                    <div class="field" style="margin-bottom: 1.5rem;">
                      <label>Confirm password</label>
                      <div class="input-wrap">
                        <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Repeat your password" required minlength="6" oninput="validate()">
                        <button type="button" class="toggle-btn" onclick="togglePw('confirmPassword')">👁</button>
                      </div>
                      <p class="match-msg" id="matchMsg"></p>
                    </div>

                    <button type="submit" id="submitBtn" disabled>Reset password</button>
                  </form>


                  <script>
                    function togglePw(id) {
                      const inp = document.getElementById(id);
                      inp.type = inp.type === 'password' ? 'text' : 'password';
                    }
                    function getStrength(pw) {
                      let s = 0;
                      if (pw.length >= 8) s++;
                      if (/[A-Z]/.test(pw)) s++;
                      if (/[0-9]/.test(pw)) s++;
                      if (/[^A-Za-z0-9]/.test(pw)) s++;
                      return s;
                    }
                    function validate() {
                      const pw = document.getElementById('newPassword').value;
                      const cpw = document.getElementById('confirmPassword').value;
                      const bar = document.getElementById('strengthBar');
                      const fill = document.getElementById('strengthFill');
                      const lbl = document.getElementById('strengthLabel');
                      const msg = document.getElementById('matchMsg');
                      const btn = document.getElementById('submitBtn');
                      const confirmInp = document.getElementById('confirmPassword');

                      if (pw.length > 0) {
                        bar.style.display = 'block'; lbl.style.display = 'block';
                        const s = getStrength(pw);
                        const colors = ['#e05050','#d97706','#6d9e40','#22c55e'];
                        const labels = ['Weak','Fair','Good','Strong'];
                        fill.style.width = [25,50,75,100][Math.min(s,3)] + '%';
                        fill.style.background = colors[Math.min(s,3)];
                        lbl.textContent = labels[Math.min(s,3)];
                        lbl.style.color = colors[Math.min(s,3)];
                      } else {
                        bar.style.display = 'none'; lbl.style.display = 'none';
                      }

                      if (cpw.length > 0) {
                        const match = pw === cpw;
                        msg.textContent = match ? '✓ Passwords match' : '✕ Passwords do not match';
                        msg.style.color = match ? '#22c55e' : '#e05050';
                        confirmInp.style.borderColor = match ? '#22c55e' : '#e05050';
                      } else {
                        msg.textContent = ''; confirmInp.style.borderColor = '#2a2550';
                      }

                      const ready = pw.length >= 6 && pw === cpw;
                      btn.disabled = !ready;
                      btn.className = ready ? 'active' : '';
                    }
                    function validateForm() {
                      const pw = document.getElementById('newPassword').value;
                      const cpw = document.getElementById('confirmPassword').value;
                      if (pw !== cpw) { alert('Passwords do not match.'); return false; }
                      return true;
                    }
                  </script>
                </body>
                </html>""";
    }

    @PostMapping("/reset-password")
    public String resetPassword(@RequestParam String token, @RequestParam String newPassword) {
        authService.resetPassword(token, newPassword);
        return "Password reset successfully";
    }

}
