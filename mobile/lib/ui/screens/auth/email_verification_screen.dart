import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../ui/providers/auth_providers.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool _isLoading = true;
  bool _isVerified = false;
  String _message = '';
  String? _token;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_token == null) {
      _token =
          ModalRoute.of(context)!.settings.arguments as String;
      _verifyEmail();
    }
  }

  Future<void> _verifyEmail() async {
    try {
      await ref
          .read(authRepositoryProvider)
          .verifyEmail(_token!);
      setState(() {
        _isVerified = true;
        _message = 'Email verified successfully!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isVerified = false;
        _message = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isLoading
                      ? Icons.hourglass_empty
                      : _isVerified
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                  size: 80,
                  color: _isLoading
                      ? AppColors.primary
                      : _isVerified
                          ? AppColors.success
                          : AppColors.error,
                ),
                const SizedBox(height: 32),
                Text(
                  _isLoading
                      ? 'Verifying Email...'
                      : _isVerified
                          ? 'Email Verified!'
                          : 'Verification Failed',
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
                  _isLoading
                      ? 'Please wait while we verify your email.'
                      : _message,
                  style: GoogleFonts.outfit(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                if (!_isLoading)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context).popUntil(
                              (route) => route.isFirst),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isVerified
                            ? AppColors.primary
                            : AppColors.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        _isVerified
                            ? 'Continue to Login'
                            : 'Back to Login',
                        style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
