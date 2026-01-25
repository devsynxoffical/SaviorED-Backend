import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../widgets/gradient_background.dart';
import '../../../routes/app_routes.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../services/storage_service.dart';
import '../../../consts/app_consts.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToOnboarding();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  Future<void> _navigateToOnboarding() async {
    try {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

      if (!authViewModel.isInitialized) {
        await authViewModel.initialize();
      }

      final hasSeenOnboarding =
          StorageService().getBool(AppConsts.hasSeenOnboardingKey) ?? false;

      if (!mounted) return;

      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      if (authViewModel.isAuthenticated) {
        Navigator.pushReplacementNamed(context, AppRoutes.castleGrounds);
        return;
      }

      if (hasSeenOnboarding) {
        // If they have seen onboarding but aren't authenticated, go to welcome/login
        Navigator.pushReplacementNamed(context, AppRoutes.welcome);
      } else {
        // First time user
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    } catch (e) {
      print("Splash navigation error: $e");
      // Fallback
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              // Main content with get_started image and text overlay
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background image
                          Image.asset(
                            'assets/images/get_started.png',
                            fit: BoxFit.contain,
                            width: 100.w,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback if image not found
                              return Container(
                                width: 100.w,
                                height: 100.h,
                                color: Colors.transparent,
                              );
                            },
                          ),

                          // Text overlay at the top - matching mockup design
                          Positioned(
                            top: 28.h,
                            left: 0,
                            right: 0,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // App Name - "Savior ED" in large, bold, dark blue
                                Text(
                                  'Savior ED',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 32.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(
                                      0xFF1565C0,
                                    ), // Dark blue matching mockup
                                    letterSpacing: -0.8,
                                    shadows: [
                                      Shadow(
                                        color: Colors.white.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 1.5.h),

                                // Tagline - "Turn study time into rewards" in smaller dark blue
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                  ),
                                  child: Text(
                                    'Turn study time into rewards',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(
                                        0xFF1565C0,
                                      ), // Dark blue matching mockup
                                      letterSpacing: 0.3,
                                      shadows: [
                                        Shadow(
                                          color: Colors.white.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // No button here as it is now a timed splash screen
            ],
          ),
        ),
      ),
    );
  }
}
