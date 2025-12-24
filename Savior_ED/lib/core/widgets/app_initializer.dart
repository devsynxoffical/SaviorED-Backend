import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../features/authentication/viewmodels/auth_viewmodel.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';

/// App Initializer - Waits for auth initialization and determines initial route
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;
  String? _initialRoute;

  @override
  void initState() {
    super.initState();
    // Defer initialization until after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initialize();
      }
    });
  }

  Future<void> _initialize() async {
    print('AppInitializer: _initialize called');
    if (!mounted) return;

    try {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

      // Wait for auth to initialize if not already initialized
      if (!authViewModel.isInitialized) {
        print('AppInitializer: Initializing AuthViewModel');
        await authViewModel.initialize();
        print('AppInitializer: AuthViewModel initialized');
      } else {
        print('AppInitializer: AuthViewModel already initialized');
      }

      if (!mounted) return;

      // Determine initial route based on authentication
      final initialRoute = authViewModel.isAuthenticated
          ? AppRoutes.castleGrounds
          : AppRoutes.splash;

      print('AppInitializer: Setting initial route to $initialRoute');

      if (mounted) {
        print(
          'AppInitializer: Calling setState. isInitialized: true, initialRoute: $initialRoute',
        );
        setState(() {
          _isInitialized = true;
          _initialRoute = initialRoute;
        });
      } else {
        print('AppInitializer: Not mounted, skipping setState');
      }
    } catch (e) {
      print('AppInitializer: Error during initialization: $e');
      // If there's an error, default to splash screen
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _initialRoute = AppRoutes.splash;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
      'AppInitializer: build called. isInitialized: $_isInitialized, initialRoute: $_initialRoute',
    );
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        if (!_isInitialized || _initialRoute == null) {
          // Show a loading screen while initializing
          return MaterialApp(
            title: 'SaviorEd',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            initialRoute: '/',
            routes: {
              '/': (context) => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            },
          );
        }

        return MaterialApp(
          key: const ValueKey('main_app'),
          title: 'SaviorEd',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          initialRoute: _initialRoute ?? AppRoutes.splash,
          routes: AppRoutes.allRoutes,
        );
      },
    );
  }
}
