import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/game_provider.dart';
import 'providers/matrix_game_provider.dart';
import 'providers/speed_tap_provider.dart';
import 'providers/radar_game_provider.dart';
import 'screens/splash_screen.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  runApp(const CogniApp());
}

class CogniApp extends StatelessWidget {
  const CogniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => MatrixGameProvider()),
        ChangeNotifierProvider(create: (_) => SpeedTapProvider()),
        ChangeNotifierProvider(create: (_) => RadarGameProvider()),
      ],
      child: MaterialApp(
        title: 'Cogni',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}
