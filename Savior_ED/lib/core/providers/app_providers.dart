import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/authentication/viewmodels/auth_viewmodel.dart';
import '../features/castle_grounds/viewmodels/castle_grounds_viewmodel.dart';
import '../features/focus_time/viewmodels/focus_time_viewmodel.dart';
import '../features/treasure_chest/viewmodels/treasure_chest_viewmodel.dart';
import '../features/leaderboard/viewmodels/leaderboard_viewmodel.dart';
import '../features/profile/viewmodels/profile_viewmodel.dart';
import '../features/inventory/viewmodels/inventory_viewmodel.dart';
import '../features/inventory/viewmodels/component_viewmodel.dart';
import '../features/base_building/viewmodels/base_building_viewmodel.dart';
import '../features/settings/viewmodels/settings_viewmodel.dart';
import 'connectivity_provider.dart';

/// App Providers - Centralized provider setup
class AppProviders {
  static List<ChangeNotifierProvider> get providers => [
    // ViewModels
    ChangeNotifierProvider<SettingsViewModel>(
      create: (_) => SettingsViewModel()..init(),
    ),
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
    ChangeNotifierProvider<ProfileViewModel>(create: (_) => ProfileViewModel()),
    ChangeNotifierProvider<InventoryViewModel>(
      create: (_) => InventoryViewModel(),
    ),
    ChangeNotifierProvider<ComponentViewModel>(
      create: (_) => ComponentViewModel(),
    ),
    ChangeNotifierProvider<BaseBuildingViewModel>(
      create: (_) => BaseBuildingViewModel(),
    ),
    ChangeNotifierProvider<ConnectivityProvider>(
      create: (_) => ConnectivityProvider(),
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
