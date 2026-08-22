import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/settings_provider.dart';
import 'home_screen.dart';

class _Page {
  final IconData icon;
  final String title;
  final String subtitle;
  const _Page(this.icon, this.title, this.subtitle);
}

const _pages = [
  _Page(Icons.edit_document, 'Create a Professional Resume',
      'Build a polished resume in minutes — no design skills needed.'),
  _Page(Icons.dashboard_customize_outlined, 'Choose from Beautiful Templates',
      '10 editable templates for every profession and career stage.'),
  _Page(Icons.palette_outlined, 'Customize Everything',
      'Colors, fonts, layout, and sections — make it truly yours.'),
  _Page(Icons.picture_as_pdf_outlined, 'Export & Share as PDF',
      'Download or share your resume instantly. Works fully offline.'),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  void _finish() {
    context.read<SettingsProvider>().completeOnboarding();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(onPressed: _finish, child: const Text('Skip')),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(p.icon, size: 64, color: theme.colorScheme.primary),
                        ),
                        const SizedBox(height: 32),
                        Text(p.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(p.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _index ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _index ? theme.colorScheme.primary : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (_index == _pages.length - 1) {
                      _finish();
                    } else {
                      _controller.nextPage(
                          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                    }
                  },
                  child: Text(_index == _pages.length - 1 ? 'Create My Resume' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
