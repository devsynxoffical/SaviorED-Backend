import 'package:flutter/material.dart';
import 'package:savior_ed/core/features/focus_time/view/focus_time_view.dart';
import 'package:savior_ed/core/features/castle_grounds/view/castle_ground_view.dart';
import 'package:savior_ed/core/features/treasure_chest/view/treasure_chest_view.dart';
import 'package:savior_ed/core/features/leaderboard/view/leaderboard_view.dart';
import 'package:savior_ed/core/features/profile/view/profile_view.dart';
import 'package:savior_ed/core/features/inventory/view/inventory_view.dart';
import 'package:savior_ed/core/features/base_building/view/base_building_view.dart';
import '../features/authentication/views/splash_view.dart';
import '../features/authentication/views/onboarding_view.dart';
import '../features/authentication/views/welcome_view.dart';
import '../features/authentication/views/login_view.dart';
import '../features/authentication/views/signup_view.dart';
import '../features/authentication/views/forgot_password_view.dart';

/// Application route constants and route definitions
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String castleGrounds = '/castle-grounds';
  static const String focusTime = '/focus-time';
  static const String treasureChest = '/treasure-chest';
  static const String leaderboard = '/leaderboard';
  static const String profile = '/profile';
  static const String inventory = '/inventory';
  static const String castleBuild = '/castle-build';
  static const String baseBuilding = '/base-building';

  // Private constructor to prevent instantiation
  AppRoutes._();

  /// All application routes
  static Map<String, WidgetBuilder> get allRoutes => {
    splash: (context) {
      try {
        return const SplashView();
      } catch (e) {
        // Fallback if there's an error building the route
        return const Scaffold(
          body: Center(child: Text('Error loading splash screen')),
        );
      }
    },
    onboarding: (context) => const OnboardingView(),
    welcome: (context) => const WelcomeView(),
    login: (context) => const LoginView(),
    signup: (context) => const SignUpView(),
    forgotPassword: (context) => const ForgotPasswordView(),
    castleGrounds: (context) => const CastleGroundsView(),
    focusTime: (context) => const FocusTimeView(),
    treasureChest: (context) => const TreasureChestView(),
    leaderboard: (context) => const LeaderboardView(),
    profile: (context) => const ProfileView(),
    inventory: (context) => const InventoryView(),
    // castleBuild: (context) => const CastleBuildView(),
    baseBuilding: (context) => const BaseBuildingView(),
  };
}
