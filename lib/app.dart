import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/resume_provider.dart';
import 'state/settings_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

class ResumeMakerApp extends StatelessWidget {
  const ResumeMakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        ChangeNotifierProvider(create: (_) => ResumeProvider()..load()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: _lightTheme,
            darkTheme: _darkTheme,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

final _seed = const Color(0xFF1E5AA8);

final ThemeData _lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.light),
  scaffoldBackgroundColor: const Color(0xFFF6F7FB),
  appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
  cardTheme: CardTheme(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    margin: EdgeInsets.zero,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  ),
);

final ThemeData _darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark),
  appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
  cardTheme: CardTheme(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    margin: EdgeInsets.zero,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  ),
);
