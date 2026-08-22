import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/template.dart' as tpl;
import '../state/settings_provider.dart';
import '../utils/constants.dart';
import 'premium_screen.dart';
import 'privacy_screen.dart';

/// Feature #38: Settings (theme, default template/paper size/font,
/// privacy, terms, about, rate, share, feedback). Feature #39: Dark Mode.
class SettingsScreen extends StatelessWidget {
  final bool embedded;
  const SettingsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    final content = ListView(
      children: [
        const _SectionLabel('Appearance'),
        ListTile(
          leading: const Icon(Icons.dark_mode_outlined),
          title: const Text('Theme'),
          subtitle: Text(switch (settings.themeMode) {
            ThemeMode.light => 'Light',
            ThemeMode.dark => 'Dark',
            ThemeMode.system => 'System Default',
          }),
          onTap: () => _pickTheme(context, settings),
        ),
        const _SectionLabel('Defaults'),
        ListTile(
          leading: const Icon(Icons.dashboard_customize_outlined),
          title: const Text('Default Template'),
          subtitle: Text(tpl.templateById(settings.defaultTemplateId).name),
          onTap: () => _pickDefaultTemplate(context, settings),
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Default Paper Size'),
          subtitle: Text(settings.defaultPaperSize),
          onTap: () => _pickPaperSize(context, settings),
        ),
        const _SectionLabel('Premium'),
        ListTile(
          leading: Icon(Icons.workspace_premium, color: settings.isPremium ? Colors.amber : null),
          title: Text(settings.isPremium ? 'Premium Active' : 'Go Premium'),
          subtitle: Text(settings.isPremium
              ? 'All templates unlocked, ads removed'
              : 'Unlock all templates & remove ads'),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PremiumScreen())),
        ),
        const _SectionLabel('About'),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Privacy Policy'),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const PrivacyScreen(title: 'Privacy Policy', text: AppConstants.privacyPolicyText))),
        ),
        ListTile(
          leading: const Icon(Icons.gavel_outlined),
          title: const Text('Terms'),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const PrivacyScreen(title: 'Terms', text: AppConstants.termsText))),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('About'),
          subtitle: const Text('Resume Maker v1.0.0'),
          onTap: () => showAboutDialog(
            context: context,
            applicationName: AppConstants.appName,
            applicationVersion: '1.0.0',
            applicationIcon: const Icon(Icons.description_outlined),
            children: const [Text('Create a professional resume in minutes — 100% offline.')],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.star_border),
          title: const Text('Rate App'),
          onTap: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Opens your app store listing')));
          },
        ),
        ListTile(
          leading: const Icon(Icons.share_outlined),
          title: const Text('Share App'),
          onTap: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Opens the share sheet')));
          },
        ),
        ListTile(
          leading: const Icon(Icons.feedback_outlined),
          title: const Text('Feedback'),
          onTap: () async {
            final uri = Uri(scheme: 'mailto', path: 'feedback@example.com', query: 'subject=Resume Maker Feedback');
            if (await canLaunchUrl(uri)) launchUrl(uri);
          },
        ),
        const SizedBox(height: 24),
      ],
    );

    if (embedded) {
      return Scaffold(appBar: AppBar(title: const Text('Settings')), body: content);
    }
    return Scaffold(appBar: AppBar(title: const Text('Settings')), body: content);
  }

  void _pickTheme(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(children: [
          for (final mode in ThemeMode.values)
            RadioListTile<ThemeMode>(
              title: Text(switch (mode) {
                ThemeMode.light => 'Light',
                ThemeMode.dark => 'Dark',
                ThemeMode.system => 'System Default',
              }),
              value: mode,
              groupValue: settings.themeMode,
              onChanged: (v) {
                settings.setThemeMode(v!);
                Navigator.pop(ctx);
              },
            ),
        ]),
      ),
    );
  }

  void _pickDefaultTemplate(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (ctx, sc) => ListView(
          controller: sc,
          children: tpl.kTemplates
              .map((t) => RadioListTile<String>(
                    title: Text(t.name),
                    value: t.id,
                    groupValue: settings.defaultTemplateId,
                    onChanged: (v) {
                      settings.setDefaultTemplate(v!);
                      Navigator.pop(ctx);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _pickPaperSize(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(children: [
          for (final size in ['A4', 'Letter'])
            RadioListTile<String>(
              title: Text(size),
              value: size,
              groupValue: settings.defaultPaperSize,
              onChanged: (v) {
                settings.setDefaultPaperSize(v!);
                Navigator.pop(ctx);
              },
            ),
        ]),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(text,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
    );
  }
}
