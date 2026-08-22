import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/settings_provider.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _proceed());
  }

  Future<void> _proceed() async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final settings = context.read<SettingsProvider>();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => settings.onboardingDone ? const HomeScreen() : const OnboardingScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(Icons.description_outlined, size: 46, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 20),
            const Text('Resume Maker',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('CV Builder & PDF',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
