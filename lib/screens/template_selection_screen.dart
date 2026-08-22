import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/template.dart' as tpl;
import '../state/resume_provider.dart';
import '../state/settings_provider.dart';
import '../widgets/template_card.dart';
import '../widgets/ad_banner_widget.dart';
import 'resume_editor_screen.dart';
import 'premium_screen.dart';

/// Feature #20: Editable Resume Templates (browse & pick one of 10).
class TemplateSelectionScreen extends StatelessWidget {
  final bool embedded;
  const TemplateSelectionScreen({super.key, this.embedded = false});

  void _select(BuildContext context, tpl.TemplateDef def) {
    final settings = context.read<SettingsProvider>();
    if (def.isPremium && !settings.isPremium) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Premium Template'),
          content: Text('"${def.name}" is a premium template. Unlock all templates with Premium.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PremiumScreen()));
              },
              child: const Text('View Premium'),
            ),
          ],
        ),
      );
      return;
    }
    final resumeProvider = context.read<ResumeProvider>();
    final resume = resumeProvider.createResume(title: '${def.name} Resume');
    resume.templateSettings.templateId = def.id;
    resume.templateSettings.colorId = def.defaultColorId;
    resume.templateSettings.fontId = def.defaultFontId;
    resumeProvider.notifyChangedAndSave();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ResumeEditorScreen(resumeId: resume.id)));
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final content = Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: tpl.kTemplates.length,
            itemBuilder: (context, i) {
              final def = tpl.kTemplates[i];
              return TemplateCard(
                def: def,
                locked: def.isPremium && !settings.isPremium,
                onTap: () => _select(context, def),
              );
            },
          ),
        ),
        const AdBannerWidget(),
        const SizedBox(height: 8),
      ],
    );

    if (embedded) {
      return Scaffold(appBar: AppBar(title: const Text('Resume Templates')), body: content);
    }
    return Scaffold(appBar: AppBar(title: const Text('Select Template')), body: content);
  }
}
