import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/section_definitions.dart';
import '../state/resume_provider.dart';
import '../state/settings_provider.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/completion_score_widget.dart';
import 'my_resumes_screen.dart';
import 'template_selection_screen.dart';
import 'resume_tips_screen.dart';
import 'settings_screen.dart';
import 'resume_editor_screen.dart';
import 'premium_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  final _pages = const [
    _HomeTab(),
    MyResumesScreen(embedded: true),
    TemplateSelectionScreen(embedded: true),
    ResumeTipsScreen(embedded: true),
    SettingsScreen(embedded: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: 'My Resumes'),
          NavigationDestination(
              icon: Icon(Icons.dashboard_customize_outlined),
              selectedIcon: Icon(Icons.dashboard_customize),
              label: 'Templates'),
          NavigationDestination(
              icon: Icon(Icons.lightbulb_outline), selectedIcon: Icon(Icons.lightbulb), label: 'Tips'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  void _startNewResume(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TemplateSelectionScreen()));
  }

  void _useSample(BuildContext context) {
    final provider = context.read<ResumeProvider>();
    final resume = provider.createFromSample(buildSampleResume());
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ResumeEditorScreen(resumeId: resume.id)));
  }

  void _continueEditing(BuildContext context, resumes) {
    if (resumes.isEmpty) return;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ResumeEditorScreen(resumeId: resumes.first.id)));
  }

  @override
  Widget build(BuildContext context) {
    final resumeProvider = context.watch<ResumeProvider>();
    final settings = context.watch<SettingsProvider>();
    final resumes = resumeProvider.resumes;
    final last = resumes.isNotEmpty ? resumes.first : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Resume Maker')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Create a professional resume in minutes',
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('${resumes.length} saved resume${resumes.length == 1 ? '' : 's'}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.white, foregroundColor: Theme.of(context).colorScheme.primary),
                          onPressed: () => _startNewResume(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Create New'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white, side: const BorderSide(color: Colors.white)),
                          onPressed: () => _useSample(context),
                          icon: const Icon(Icons.auto_awesome_outlined),
                          label: const Text('Use Sample'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.play_circle_outline,
                  label: 'Continue Editing',
                  enabled: last != null,
                  onTap: () => _continueEditing(context, resumes),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  icon: Icons.folder_open_outlined,
                  label: 'View Saved',
                  enabled: resumes.isNotEmpty,
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const MyResumesScreen())),
                ),
              ),
            ],
          ),
          if (last != null) ...[
            const SizedBox(height: 16),
            Text('Last edited: ${last.title}',
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            CompletionScoreWidget(resume: last),
          ],
          if (!settings.isPremium) ...[
            const SizedBox(height: 16),
            _PremiumBanner(),
          ],
          const SizedBox(height: 16),
          const Center(child: AdBannerWidget()),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 6),
                Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber.shade50,
      child: ListTile(
        leading: const Icon(Icons.workspace_premium, color: Colors.amber),
        title: const Text('Go Premium', style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: const Text('Unlock all templates, remove ads, and more.'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PremiumScreen())),
      ),
    );
  }
}
