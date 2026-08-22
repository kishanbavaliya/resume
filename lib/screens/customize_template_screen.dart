import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/resume.dart';
import '../models/template.dart' as tpl;
import '../state/resume_provider.dart';
import '../state/settings_provider.dart';
import '../widgets/resume_preview_widget.dart';
import 'template_selection_screen.dart';
import 'premium_screen.dart';

/// Feature #21: Template Customization — colors, typography, layout,
/// display controls (photo/icons/skill bars/address/social links),
/// plus ATS-Friendly Mode (feature #35).
class CustomizeTemplateScreen extends StatefulWidget {
  final Resume resume;
  const CustomizeTemplateScreen({super.key, required this.resume});

  @override
  State<CustomizeTemplateScreen> createState() => _CustomizeTemplateScreenState();
}

class _CustomizeTemplateScreenState extends State<CustomizeTemplateScreen> {
  void _save() {
    setState(() {});
    context.read<ResumeProvider>().notifyChangedAndSave(widget.resume);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.resume.templateSettings;
    final def = tpl.templateById(t.templateId);
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Customize Template'), actions: [
        TextButton.icon(
          onPressed: () async {
            await Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const TemplateSelectionScreen()));
          },
          icon: const Icon(Icons.swap_horiz, color: Colors.white),
          label: const Text('Change', style: TextStyle(color: Colors.white)),
        ),
      ]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 220,
              child: ResumePreview(resume: widget.resume),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                Text('Using: ${def.name}', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 12),
                Text('Color', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: tpl.kColorOptions.map((c) {
                    final selected = t.colorId == c.id;
                    return GestureDetector(
                      onTap: () {
                        t.colorId = c.id;
                        _save();
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c.color,
                          shape: BoxShape.circle,
                          border: selected ? Border.all(color: Colors.black, width: 2.5) : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text('Typography', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: tpl.kFontOptions.map((f) {
                    final selected = t.fontId == f.id;
                    return ChoiceChip(
                      label: Text(f.name),
                      selected: selected,
                      onSelected: (_) {
                        t.fontId = f.id;
                        _save();
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text('Display Controls', style: Theme.of(context).textTheme.labelLarge),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Photo'),
                  value: widget.resume.personalInfo.showPhoto,
                  onChanged: (v) {
                    widget.resume.personalInfo.showPhoto = v;
                    _save();
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Icons'),
                  value: t.showIcons,
                  onChanged: (v) {
                    t.showIcons = v;
                    _save();
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Skill Bars'),
                  value: t.showSkillBars,
                  onChanged: (v) {
                    t.showSkillBars = v;
                    _save();
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Address'),
                  value: widget.resume.personalInfo.showAddress,
                  onChanged: (v) {
                    widget.resume.personalInfo.showAddress = v;
                    _save();
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Social Links'),
                  value: widget.resume.personalInfo.showSocialLinks,
                  onChanged: (v) {
                    widget.resume.personalInfo.showSocialLinks = v;
                    _save();
                  },
                ),
                const Divider(height: 32),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('ATS-Friendly Mode'),
                  subtitle: const Text('Single column, simple fonts, no graphics'),
                  value: t.atsMode,
                  onChanged: (v) {
                    t.atsMode = v;
                    _save();
                  },
                ),
                if (t.atsMode)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'ATS compatibility can vary by employer/software.',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                    ),
                  ),
                if (!settings.isPremium) ...[
                  const SizedBox(height: 20),
                  Card(
                    color: Colors.amber.shade50,
                    child: ListTile(
                      leading: const Icon(Icons.workspace_premium, color: Colors.amber),
                      title: const Text('Unlock premium colors, fonts & layouts'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => const PremiumScreen())),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
