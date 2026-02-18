import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/utils/validators.dart';
import '../services/auth_service.dart';

const _kAccent = Color(0xFF252525);
const _kBackground = Color(0xFFF7F7F7);

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController =
      TextEditingController(); // ← Un seul champ pour le nom complet
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = 'CLIENT';

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Passwords do not match'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = RegisterRequest(
        name: _nameController.text.trim(), // ← Full name
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        role: _selectedRole,
      );

      final response = await _authService.register(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Account created successfully, ${response.firstName}!',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground, // ← updated background color
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 56, // ← bigger logo
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 8,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create your\nAccount',
                        style: TextStyle(
                          color: _kAccent,
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.0,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Join Homely and find your perfect home',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 36),

                      _buildLabeledField(
                        label: 'Full Name',
                        child: _buildTextField(
                          controller: _nameController,
                          hintText: 'Mohamed El Amraoui',
                          validator: Validators.validateName,
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildLabeledField(
                        label: 'Email Address',
                        child: _buildTextField(
                          controller: _emailController,
                          hintText: 'you@example.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildLabeledField(
                        label: 'Phone Number',
                        child: _buildTextField(
                          controller: _phoneController,
                          hintText: '+212 610893678',
                          keyboardType: TextInputType.phone,
                          validator: Validators.validatePhone,
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildLabeledField(
                        label: 'Password',
                        child: _buildTextField(
                          controller: _passwordController,
                          hintText: 'Enter your password',
                          obscureText: _obscurePassword,
                          validator: Validators.validatePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF888888),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildLabeledField(
                        label: 'Confirm Password',
                        child: _buildTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Re-enter your password',
                          obscureText: _obscureConfirmPassword,
                          validator: Validators.validatePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF888888),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(
                                () => _obscureConfirmPassword =
                                    !_obscureConfirmPassword,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'I am a:',
                        style: TextStyle(
                          color: _kAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildRoleOption(
                              'CLIENT',
                              Icons.search_outlined,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildRoleOption(
                              'SELLER',
                              Icons.home_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      _buildSignupButton(),
                      const SizedBox(height: 28),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: _kAccent,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _kAccent,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(
        color: _kAccent,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF999999),
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFBBB8B2), width: 1.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFBBB8B2), width: 1.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _kAccent, width: 2.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 2.2),
        ),
        filled: true,
        fillColor: _kBackground, // same as page background
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    );
  }

  Widget _buildRoleOption(String role, IconData icon) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? _kAccent : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _kAccent : const Color(0xFFBBB8B2),
            width: isSelected ? 2.0 : 1.8,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color.fromRGBO(37, 37, 37, 0.15),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.04),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              role,
              style: TextStyle(
                color: isSelected ? Colors.white : _kAccent,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signup,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kAccent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color.fromRGBO(37, 37, 37, 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}
