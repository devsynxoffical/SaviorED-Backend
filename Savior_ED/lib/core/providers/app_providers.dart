import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/authentication/viewmodels/auth_viewmodel.dart';
import '../features/castle_grounds/viewmodels/castle_grounds_viewmodel.dart';
import '../features/focus_time/viewmodels/focus_time_viewmodel.dart';
import '../features/treasure_chest/viewmodels/treasure_chest_viewmodel.dart';
import '../features/leaderboard/viewmodels/leaderboard_viewmodel.dart';

/// App Providers - Centralized provider setup
class AppProviders {
  static List<ChangeNotifierProvider> get providers => [
    // ViewModels
    ChangeNotifierProvider<AuthViewModel>(create: (_) => AuthViewModel()),
    ChangeNotifierProvider<CastleGroundsViewModel>(
      create: (_) => CastleGroundsViewModel(),
    ),
    ChangeNotifierProvider<FocusTimeViewModel>(
      create: (_) => FocusTimeViewModel(),
    ),
    ChangeNotifierProvider<TreasureChestViewModel>(
      create: (_) => TreasureChestViewModel(),
    ),
    ChangeNotifierProvider<LeaderboardViewModel>(
      create: (_) => LeaderboardViewModel(),
    ),
  ];

  /// MultiProvider widget wrapper
  static Widget wrap({
    required Widget child,
    List<ChangeNotifierProvider>? additionalProviders,
  }) {
    final allProviders = [
      ...providers,
      if (additionalProviders != null) ...additionalProviders,
    ];

    return MultiProvider(providers: allProviders, child: child);
  }
}
