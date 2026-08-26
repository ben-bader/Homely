package com.homely.common.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class EmailService {

    private static final Logger log = LoggerFactory.getLogger(EmailService.class);

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username:homely.support@gmail.com}")
    private String fromAddress;

    @Value("${app.backend.url:http://localhost:8082}")
    private String backendUrl;

    public void sendHtmlEmail(String to, String subject, String html) {
        try {
            MimeMessage mimeMessage = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, "utf-8");
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setFrom(fromAddress);
            helper.setText(html, true);
            mailSender.send(mimeMessage);
        } catch (MessagingException ex) {
            log.error("Failed to send HTML email to {}: {}", to, ex.getMessage(), ex);
            // Fallback: try to send a simple text (best-effort)
            try {
                MimeMessage mimeMessage = mailSender.createMimeMessage();
                MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, "utf-8");
                helper.setTo(to);
                helper.setSubject(subject);
                helper.setFrom(fromAddress);
                // strip tags as naive fallback
                String fallback = html.replaceAll("<[^>]*>", "");
                helper.setText(fallback, false);
                mailSender.send(mimeMessage);
            } catch (Exception e) {
                log.error("Fallback plain email also failed for {}: {}", to, e.getMessage(), e);
            }
        }
    }

    public void sendVerificationEmail(String to, String verificationLink) {
        String html = buildVerificationTemplate(verificationLink);
        sendHtmlEmail(to, "Verify Your Email", html);
    }

    public void sendPasswordResetEmail(String to, String resetLink, long expiryMinutes) {
        String html = buildPasswordResetTemplate(resetLink, expiryMinutes);
        sendHtmlEmail(to, "Reset Your Password", html);
    }

    public void sendPasswordResetCodeEmail(String to, String resetCode, long expiryMinutes) {
        String html = buildPasswordResetCodeTemplate(resetCode, expiryMinutes);
        sendHtmlEmail(to, "Your Password Reset Code", html);
    }

    private String buildVerificationTemplate(String verificationLink) {
        String brandColor = "#4F46E5";
        return "<!doctype html>"
                + "<html lang=\"en\"><head><meta charset=\"utf-8\"/>"
                + "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">"
                + "<title>Verify your email</title>"
                + "<style>body{background:#F8FAFC;margin:0;padding:20px;font-family:Arial,Helvetica,sans-serif;color:#0F172A;} .container{max-width:600px;margin:0 auto;} .card{background:#ffffff;border-radius:12px;padding:28px;box-shadow:0 6px 18px rgba(15,23,42,0.06);} .logo{font-weight:700;color:" + brandColor + ";font-size:20px;margin-bottom:8px;} .h1{font-size:20px;margin:16px 0 8px;} .p{color:#334155;font-size:15px;line-height:1.45;} .btn{display:inline-block;padding:12px 22px;background:" + brandColor + ";color:#fff;border-radius:8px;text-decoration:none;margin-top:18px;} .small{font-size:13px;color:#64748B;margin-top:18px;} .footer{font-size:12px;color:#94A3B8;margin-top:20px;text-align:center;}</style>"
                + "</head><body><div class=\"container\">"
                + "<div class=\"card\">"
                + "<div style=\"text-align:center;margin-bottom:18px;\">"
                + "<img src=\"/images/logo_homely.png\" alt=\"Homely logo\" width=\"120\" style=\"display:block;margin:0 auto;max-width:120px;height:auto;\">"
                + "</div>"
                + "<div class=\"logo\">Homely</div>"
                + "<div class=\"h1\">Welcome to Homely</div>"
                + "<div class=\"p\">Thanks for creating an account. Please verify your email address to activate your account.</div>"
                + "<a class=\"btn\" href=\"" + verificationLink + "\">Verify Email</a>"
                + "<div class=\"small\">If the button doesn't work, copy and paste the following link into your browser:<br/><a href=\"" + verificationLink + "\">" + verificationLink + "</a></div>"
                + "</div>"
                + "<div class=\"footer\">© " + java.time.Year.now().getValue() + " Homely. All rights reserved.</div>"
                + "</div></body></html>";
    }

    private String buildPasswordResetTemplate(String resetLink, long expiryMinutes) {
        String brandColor = "#4F46E5";
        return "<!doctype html>"
                + "<html lang=\"en\"><head><meta charset=\"utf-8\"/>"
                + "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">"
                + "<title>Reset your password</title>"
                + "<style>body{background:#F8FAFC;margin:0;padding:20px;font-family:Arial,Helvetica,sans-serif;color:#0F172A;} .container{max-width:600px;margin:0 auto;} .card{background:#ffffff;border-radius:12px;padding:28px;box-shadow:0 6px 18px rgba(15,23,42,0.06);} .logo{font-weight:700;color:" + brandColor + ";font-size:20px;margin-bottom:8px;} .h1{font-size:20px;margin:16px 0 8px;} .p{color:#334155;font-size:15px;line-height:1.45;} .btn{display:inline-block;padding:12px 22px;background:" + brandColor + ";color:#fff;border-radius:8px;text-decoration:none;margin-top:18px;} .muted{font-size:13px;color:#64748B;margin-top:16px;} .footer{font-size:12px;color:#94A3B8;margin-top:20px;text-align:center;}</style>"
                + "</head><body><div class=\"container\">"
                + "<div class=\"card\">"
                + "<div style=\"text-align:center;margin-bottom:18px;\">"
                + "<img src=\"/images/logo_homely.png\" alt=\"Homely logo\" width=\"120\" style=\"display:block;margin:0 auto;max-width:120px;height:auto;\">"
                + "</div>"
                + "<div class=\"logo\">Homely</div>"
                + "<div class=\"h1\">Reset your password</div>"
                + "<div class=\"p\">We received a request to reset the password for your Homely account. Click the button below to choose a new password.</div>"
                + "<a class=\"btn\" href=\"" + resetLink + "\">Reset Password</a>"
                + "<div class=\"muted\">This link will expire in approximately " + expiryMinutes + " minutes. If you did not request a password reset, you can safely ignore this email.</div>"
                + "<div class=\"muted\">If the button doesn't work, copy and paste the following link into your browser:<br/><a href=\"" + resetLink + "\">" + resetLink + "</a></div>"
                + "</div>"
                + "<div class=\"footer\">© " + java.time.Year.now().getValue() + " Homely. All rights reserved.</div>"
                + "</div></body></html>";
    }

    private String buildPasswordResetCodeTemplate(String resetCode, long expiryMinutes) {
        String brandColor = "#4F46E5";
        return "<!doctype html>"
                + "<html lang=\"en\"><head><meta charset=\"utf-8\"/>"
                + "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">"
                + "<title>Your Password Reset Code</title>"
                + "<style>body{background:#F8FAFC;margin:0;padding:20px;font-family:Arial,Helvetica,sans-serif;color:#0F172A;} .container{max-width:600px;margin:0 auto;} .card{background:#ffffff;border-radius:12px;padding:28px;box-shadow:0 6px 18px rgba(15,23,42,0.06);} .logo{font-weight:700;color:" + brandColor + ";font-size:20px;margin-bottom:8px;} .h1{font-size:20px;margin:16px 0 8px;} .p{color:#334155;font-size:15px;line-height:1.45;} .code-box{background:#F1F5F9;border:1px solid #E2E8F0;border-radius:8px;padding:20px;text-align:center;margin:20px 0;} .code{font-size:32px;font-weight:bold;letter-spacing:2px;color:" + brandColor + ";font-family:'Courier New',monospace;} .muted{font-size:13px;color:#64748B;margin-top:16px;} .footer{font-size:12px;color:#94A3B8;margin-top:20px;text-align:center;}</style>"
                + "</head><body><div class=\"container\">"
                + "<div class=\"card\">"
                + "<div style=\"text-align:center;margin-bottom:18px;\">"
                + "<img src=\"/images/logo_homely.png\" alt=\"Homely logo\" width=\"120\" style=\"display:block;margin:0 auto;max-width:120px;height:auto;\">"
                + "</div>"
                + "<div class=\"logo\">Homely</div>"
                + "<div class=\"h1\">Reset Your Password</div>"
                + "<div class=\"p\">We received a request to reset the password for your Homely account. Use the code below to reset your password.</div>"
                + "<div class=\"code-box\">"
                + "<div class=\"code\">" + resetCode + "</div>"
                + "</div>"
                + "<div class=\"muted\"><strong>Important:</strong> This code will expire in " + expiryMinutes + " minutes. Do not share this code with anyone.</div>"
                + "<div class=\"muted\">If you did not request a password reset, you can safely ignore this email.</div>"
                + "</div>"
                + "<div class=\"footer\">© " + java.time.Year.now().getValue() + " Homely. All rights reserved.</div>"
                + "</div></body></html>";
    }}