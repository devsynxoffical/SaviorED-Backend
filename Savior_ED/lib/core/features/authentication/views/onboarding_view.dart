import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../widgets/gradient_background.dart';
import '../../../routes/app_routes.dart';
import '../../../services/storage_service.dart';
import '../../../consts/app_consts.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                children: [
                  SizedBox(height: 7.h),

                  // Title - "UNLOCK YOUR POTENTIAL" in large, bold, dark blue
                  Text(
                    'UNLOCK YOUR POTENTIAL',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color.fromARGB(
                        255,
                        23,
                        84,
                        150,
                      ), // Dark blue matching mockup
                      letterSpacing: 0.5,
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Description text in dark blue
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Text(
                      'SaviorEd is a gamified study tracker that helps you turn your focus into rewards. Earn coins, level up your castle, and unlock prizes as you study!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color.fromARGB(
                          255,
                          23,
                          84,
                          150,
                        ), // Dark blue matching mockup
                        height: 1.5,
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Onboarding image in center
                  Center(
                    child: Image.asset(
                      'assets/images/onboarding.png',
                      fit: BoxFit.contain,
                      width: 90.w,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 90.w,
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20.sp),
                          ),
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50.sp,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Continue Button - light blue matching mockup
                  SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: const Color(
                        0xFF81D4FA,
                      ), // Light blue matching mockup
                      borderRadius: BorderRadius.circular(30.sp),
                      elevation: 4,
                      shadowColor: const Color(0xFF81D4FA).withOpacity(0.3),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30.sp),
                        onTap: () async {
                          // Mark onboarding as seen
                          await StorageService().saveBool(
                            AppConsts.hasSeenOnboardingKey,
                            true,
                          );

                          if (!context.mounted) return;

                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.welcome,
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 2.2.h),
                          alignment: Alignment.center,
                          child: Text(
                            'CONTINUE',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
