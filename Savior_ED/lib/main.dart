import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/app_providers.dart';
import 'core/services/storage_service.dart';
import 'core/widgets/app_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize StorageService before running the app
  await StorageService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: const AppInitializer(),
    );
  }
}
