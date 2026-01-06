import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../widgets/gradient_background.dart';
import '../../../services/toast_service.dart';
import '../../../consts/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';
import '../../../routes/app_routes.dart';
import '../viewmodels/auth_viewmodel.dart';

/// Sign Up View - Matching mockup exactly
class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  double _passwordStrengthValue = 0.0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength(String password) {
    setState(() {
      if (password.isEmpty) {
        _passwordStrengthValue = 0.0;
      } else if (password.length < 6) {
        _passwordStrengthValue = 0.3; // Weak
      } else if (password.length < 10) {
        _passwordStrengthValue = 0.6; // Medium
      } else {
        _passwordStrengthValue = 1.0; // Strong
      }
    });
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ToastService.showError(
          context,
          title: 'Error',
          description: 'Please agree to the Terms and Privacy Policy',
        );
        return;
      }

      final authViewModel = context.read<AuthViewModel>();
      final success = await authViewModel.register(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        ToastService.showSuccess(
          context,
          title: 'Success',
          description: 'Account created successfully',
        );
        Navigator.pushReplacementNamed(context, AppRoutes.castleGrounds);
      } else {
        ToastService.showError(
          context,
          title: 'Error',
          description: authViewModel.errorMessage ?? 'Sign up failed',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      colors: const [
        Color(0xFFA5D6A7), // Green 200 - Top
        Color(0xFFE3F2FD), // Blue 50 - Bottom
      ],
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              if (authViewModel.isLoading) {
                return const LoadingWidget(message: 'Creating account...');
              }

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 6.h),

                      // Title
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Create Your Account',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF003300), // Dark Green
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      SizedBox(height: 5.h),

                      // Full Name Field
                      _buildShadowTextField(
                        controller: _nameController,
                        hint: 'Full Name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 2.5.h),

                      // Email Address Field
                      _buildShadowTextField(
                        controller: _emailController,
                        hint: 'Email Address',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 2.5.h),

                      // Password Field
                      _buildShadowTextField(
                        controller: _passwordController,
                        hint: 'Password',
                        obscureText: _obscurePassword,
                        onChanged: _checkPasswordStrength,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey,
                            size: 20.sp,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 2.5.h),

                      // Confirm Password Field
                      _buildShadowTextField(
                        controller: _confirmPasswordController,
                        hint: 'Confirm Password',
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey,
                            size: 20.sp,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      // Password Strength Indicator
                      if (_passwordController.text.isNotEmpty) ...[
                        SizedBox(height: 1.5.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Password Strength',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: const Color(0xFF003300),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 0.8.h),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: _passwordStrengthValue,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _passwordStrengthValue >= 0.6
                                        ? AppColors.success
                                        : AppColors.warning,
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: 3.h),

                      // Sign Up Button
                      CustomButton(
                        text: 'Sign Up',
                        backgroundColor: const Color(0xFF4285F4), // Google Blue
                        borderRadius: 50.sp,
                        height: 6.5.h,
                        onPressed: _handleSignUp,
                        textColor: Colors.white,
                      ),

                      SizedBox(height: 2.5.h),

                      // Continue with Google Button
                      _buildGoogleButton(),

                      SizedBox(height: 2.5.h),

                      // Terms and Privacy Policy Checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _agreeToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreeToTerms = value ?? false;
                                });
                              },
                              activeColor: const Color(0xFF4285F4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Wrap(
                              children: [
                                Text(
                                  'I agree to the ',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.black87,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // Handle Terms
                                  },
                                  child: Text(
                                    'Terms',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color(0xFF4285F4),
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  ' and ',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.black87,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // Handle Privacy Policy
                                  },
                                  child: Text(
                                    'Privacy Policy',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color(0xFF4285F4),
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShadowTextField({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: 6.5.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(200), // pill shape
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      alignment: Alignment.center,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
        textAlign: TextAlign.start, // Start alignment (left)
        textAlignVertical: TextAlignVertical.center, // Vertically center
        style: TextStyle(fontSize: 16.sp, color: Colors.black87),

        decoration: InputDecoration(
          isDense: true, // 💚 Removes extra height
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16.sp),

          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0), // Vertically centered

          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,

          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Container(
      width: double.infinity,
      height: 6.5.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50.sp),
          onTap: () async {
            final authViewModel = context.read<AuthViewModel>();
            final success = await authViewModel.loginWithGoogle();
            if (!mounted) return;
            if (success) {
              // Navigate to castle grounds on successful login
              Navigator.pushReplacementNamed(context, AppRoutes.castleGrounds);
            } else {
              ToastService.showError(
                context,
                title: "Google Sign In",
                description: authViewModel.errorMessage ?? "Google sign in is not available. Please use email/password.",
              );
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/google_logo.png',
                width: 24.sp,
                height: 24.sp,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.g_mobiledata,
                  size: 28.sp,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Continue with Google',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
