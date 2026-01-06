import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../widgets/gradient_background.dart';
import '../../../services/toast_service.dart';
import '../../../consts/app_sizes.dart';
import '../../../routes/app_routes.dart';
import '../viewmodels/auth_viewmodel.dart';

/// Welcome Back / Authentication Options Screen - Matching mockup exactly
class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(AppSizes.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 12.h),
                
                // Title - WELCOME BACK! LET'S GET YOU STARTED ON YOUR FOCUS JOURNEY.
                Text(
                  'WELCOME BACK!\nLET\'S GET YOU STARTED\nON YOUR FOCUS JOURNEY.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B5E20), // Dark green/blue matching mockup
                    height: 1.3,
                    letterSpacing: 0.5,
                  ),
                ),
                
                SizedBox(height: 10.h),
                
                // Sign In Button - Light blue matching mockup
                SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: const Color(0xFF81D4FA), // Light blue matching mockup
                    borderRadius: BorderRadius.circular(28.sp),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28.sp),
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 2.0.h),
                        alignment: Alignment.center,
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 1.5.h),
                
                // Sign Up Button - Light green matching mockup
                SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: const Color(0xFF81C784), // Light green matching mockup
                    borderRadius: BorderRadius.circular(28.sp),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28.sp),
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.signup);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 2.0.h),
                        alignment: Alignment.center,
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 1.5.h),
                
                // Google Sign In Button - White with border matching mockup
                _buildGoogleButton(context),
                
                SizedBox(height: 1.5.h),
                
                // Forgot Password Link - Blue text without underline
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.forgotPassword);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  ),
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF2196F3), // Blue color
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.sp),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(28.sp),
          onTap: () async {
            final authViewModel = context.read<AuthViewModel>();
            final success = await authViewModel.loginWithGoogle();
            if (!context.mounted) return;
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
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 1.5.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28.sp),
              border: Border.all(
                color: Colors.grey.shade400, // Gray border matching mockup
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google logo from assets
                Image.asset(
                  'assets/images/google_logo.png',
                  width: 22.sp,
                  height: 22.sp,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.g_mobiledata,
                    size: 22.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  'Continue with Google',
                  style: TextStyle(
                    color: Colors.grey.shade700, // Dark gray text matching mockup
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
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
