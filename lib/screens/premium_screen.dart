import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/settings_provider.dart';

/// Feature #41/#43: Premium Version & Premium Template System.
/// No real payment SDK is wired up (that requires a Play/App Store
/// account) — this screen is ready to connect to `in_app_purchase`
/// and simply flips the local "isPremium" flag for now so you can
/// see/test the unlocked behaviour end-to-end.
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final features = [
      'All 10 resume templates',
      'No ads',
      'Advanced customization (colors, fonts, layouts)',
      'Unlimited resumes',
      'Premium colors & fonts',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Icon(Icons.workspace_premium, size: 72, color: Colors.amber.shade600),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text('Upgrade to Premium', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(f)),
                  ],
                ),
              )),
          const SizedBox(height: 24),
          if (settings.isPremium)
            Center(
              child: FilledButton.icon(
                onPressed: () => settings.setPremium(false),
                icon: const Icon(Icons.close),
                label: const Text('Deactivate Premium (test)'),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  await settings.setPremium(true);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Premium unlocked!')));
                    Navigator.pop(context);
                  }
                },
                child: const Text('Upgrade Now'),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            'Wire this button up to in_app_purchase / Play Billing for a real purchase flow — see README.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
