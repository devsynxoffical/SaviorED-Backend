import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../widgets/gradient_background.dart';
import '../../../services/toast_service.dart';
import '../../../consts/app_colors.dart';
import '../../../consts/app_sizes.dart';
import '../../../consts/app_strings.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/loading_widget.dart';

/// Forgot Password View - Matching login screen design pattern
class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ToastService.showSuccess(
        context,
        title: AppStrings.success,
        description: 'Password reset link sent to your email',
      );

      // Navigate back to login after showing success message
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: _isLoading
              ? const LoadingWidget(message: 'Sending reset link...')
              : SingleChildScrollView(
                  padding: EdgeInsets.all(AppSizes.paddingLarge),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 14.h),

                        // Title - Centered with elegant styling
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Forgot Password',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: 1.0,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 2.h),

                        // Subtitle
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Text(
                            'Enter your email address and we\'ll send you a link to reset your password.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),

                        SizedBox(height: 6.h),

                        // Email Address Field
                        CustomTextField(
                          hint: 'Email Address',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          fillColor: Colors.white,
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

                        SizedBox(height: 5.h),

                        // Submit Button - Blue with pill-shaped
                        CustomButton(
                          text: 'Send Reset Link',
                          backgroundColor: AppColors.secondary,
                          borderRadius: 50.sp,
                          onPressed: _handleResetPassword,
                        ),

                        SizedBox(height: 3.h),

                        // Back to Login Link
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Back to Sign In',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

