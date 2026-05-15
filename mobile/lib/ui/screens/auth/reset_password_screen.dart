import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../ui/providers/auth_providers.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String? token;
  final String? email;
  
  const ResetPasswordScreen({
    super.key,
    this.token,
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
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _passwordReset = false;
  String? _token;
  String? _email;

  @override
  void initState() {
    super.initState();
    // Get token and email from constructor or route arguments
    _token = widget.token;
    _email = widget.email;
    
    if (_email != null) {
      _emailController.text = _email!;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Try to get from route arguments if not already set
    if (_token == null || _email == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null) {
        if (args is Map<String, dynamic>) {
          _token = args['token'] as String?;
          _email = args['email'] as String?;
          if (_email != null && _emailController.text.isEmpty) {
            _emailController.text = _email!;
          }
        } else if (args is String) {
          // Legacy support for token-only argument
          _token = args;
        }
      }
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (_token == null || _email == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Invalid reset link. Please try again.',
            style: GoogleFonts.outfit()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)),
      ));
      return;
    }
    if (_passwordController.text !=
        _confirmPasswordController.text) {
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
            token: _token!,
            email: _email!,
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
          );
      setState(() => _passwordReset = true);
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
    _emailController.dispose();
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
          Text('Enter your new password below.',
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
                fontSize: 16,
                height: 1.5,
              )),
          const SizedBox(height: 40),
          _buildEmailField(),
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
              if (v == null || v.isEmpty)
                return 'Please confirm your password';
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
          readOnly: true,
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
}
