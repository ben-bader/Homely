import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../ui/providers/auth_providers.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String? email;

  const ResetPasswordScreen({
    super.key,
    this.email,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isResending = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _passwordReset = false;
  int _resendSecondsRemaining = 0;
  Timer? _resendTimer;
  String? _email;

  @override
  void initState() {
    super.initState();
    // Get email from constructor or route arguments
    _email = widget.email;
    
    if (_email != null) {
      _emailController.text = _email!;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _email = args['email'] as String?;
      final cooldown = args['resendCooldownSeconds'] as int?;
      if (_email != null && _emailController.text.isEmpty) {
        _emailController.text = _email!;
      }
      if (cooldown != null && cooldown > 0) {
        _startResendTimer(cooldown);
      }
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter the email for this account.',
            style: GoogleFonts.outfit()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)),
      ));
      return;
    }
    final code = _codeController.text.trim();
    if (code.isEmpty || code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter the 6-digit reset code.',
            style: GoogleFonts.outfit()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)),
      ));
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Passwords do not match',
            style: GoogleFonts.outfit()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)),
      ));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).resetPassword(
            email: email,
            code: code,
            password: _passwordController.text,
          );
      setState(() => _passwordReset = true);
    } on ApiException catch (e) {
      if (mounted) {
        final message = e.statusCode == 404
            ? 'Invalid reset code or email. Please check your code and try again.'
            : e.message;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message, style: GoogleFonts.outfit()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(e.toString(), style: GoogleFonts.outfit()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: 28, vertical: 16),
          child: _passwordReset
              ? _buildSuccessView()
              : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reset Password',
              style: GoogleFonts.outfit(
                color: AppColors.accent,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              )),
          const SizedBox(height: 12),
          Text('Enter your email, code, and new password below.',
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
                fontSize: 16,
                height: 1.5,
              )),
          const SizedBox(height: 40),
          _buildEmailField(),
          const SizedBox(height: 18),
          Text(
            'Enter the 6-digit code from your email, then set a new password.',
            style: GoogleFonts.outfit(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          _buildCodeField(),
          const SizedBox(height: 16),
          _buildResendSection(),
          const SizedBox(height: 24),
          _buildPasswordField(
            label: 'New Password',
            controller: _passwordController,
            hint: 'Enter new password',
            obscure: _obscurePassword,
            toggle: () => setState(
                () => _obscurePassword = !_obscurePassword),
            validator: Validators.validatePassword,
          ),
          const SizedBox(height: 24),
          _buildPasswordField(
            label: 'Confirm New Password',
            controller: _confirmPasswordController,
            hint: 'Confirm new password',
            obscure: _obscureConfirmPassword,
            toggle: () => setState(() =>
                _obscureConfirmPassword =
                    !_obscureConfirmPassword),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Please confirm your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(
                                  Colors.white)))
                  : Text('Reset Password',
                      style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email',
            style: GoogleFonts.outfit(
                color: AppColors.accent,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.outfit(color: AppColors.accent),
          decoration: InputDecoration(
            hintText: 'your@email.com',
            hintStyle: GoogleFonts.outfit(
                color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 18),
          ),
          validator: Validators.validateEmail,
        ),
      ],
    );
  }

  Widget _buildResendSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            _resendSecondsRemaining > 0
                ? 'Resend available in ${_resendSecondsRemaining}s'
                : 'Didn\'t receive a code? You can resend it.',
            style: GoogleFonts.outfit(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
        TextButton(
          onPressed: (_resendSecondsRemaining > 0 || _isResending)
              ? null
              : _resendCode,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            backgroundColor: _resendSecondsRemaining > 0
                ? AppColors.surface
                : AppColors.primary,
          ),
          child: _isResending
              ? SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Resend Code',
                  style: GoogleFonts.outfit(
                    color: _resendSecondsRemaining > 0
                        ? AppColors.textSecondary
                        : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reset Code',
            style: GoogleFonts.outfit(
                color: AppColors.accent,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          style: GoogleFonts.outfit(color: AppColors.accent),
          decoration: InputDecoration(
            hintText: 'Enter 6-digit code',
            hintStyle: GoogleFonts.outfit(
                color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 18),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter the reset code';
            }
            if (value.trim().length != 6) {
              return 'The reset code must be 6 digits';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback toggle,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.outfit(
                color: AppColors.accent,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          style: GoogleFonts.outfit(color: AppColors.accent),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(
                color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 18),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppColors.textSecondary,
              ),
              onPressed: toggle,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Icon(Icons.check_circle_outline,
            size: 80, color: AppColors.success),
        const SizedBox(height: 32),
        Text(
          'Password Reset\nSuccessful!',
          style: GoogleFonts.outfit(
            color: AppColors.accent,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Your password has been reset successfully.',
          style: GoogleFonts.outfit(
            color: AppColors.textSecondary,
            fontSize: 16,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text('Back to Login',
                style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  void _startResendTimer(int seconds) {
    _resendTimer?.cancel();
    setState(() {
      _resendSecondsRemaining = seconds;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSecondsRemaining <= 1) {
        timer.cancel();
        setState(() => _resendSecondsRemaining = 0);
        return;
      }
      setState(() => _resendSecondsRemaining -= 1);
    });
  }

  Future<void> _resendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || Validators.validateEmail(email) != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a valid email before resending.',
            style: GoogleFonts.outfit()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)),
      ));
      return;
    }
    setState(() {
      _isResending = true;
      _resendSecondsRemaining = 0;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .requestPasswordReset(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'A fresh reset code was sent to $email.',
          style: GoogleFonts.outfit(),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)),
      ));
      _startResendTimer(60);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString(), style: GoogleFonts.outfit()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
        ));
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }
}
