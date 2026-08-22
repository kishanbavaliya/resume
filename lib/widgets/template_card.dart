import 'package:flutter/material.dart';
import '../models/resume.dart';
import '../models/template.dart' as tpl;
import 'resume_preview_widget.dart';

class TemplateCard extends StatelessWidget {
  final tpl.TemplateDef def;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  const TemplateCard({
    super.key,
    required this.def,
    required this.onTap,
    this.selected = false,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    // Build a tiny throwaway resume just to render an accurate thumbnail.
    final preview = Resume(
      title: 'preview',
      summary: 'Experienced professional with a track record of delivering results.',
      personalInfo: PersonalInfo(fullName: 'Jordan Lee', jobTitle: def.name, showPhoto: false),
      templateSettings: TemplateSettings(
        templateId: def.id,
        colorId: def.defaultColorId,
        fontId: def.defaultFontId,
      ),
      sections: [
        ResumeSection(type: SectionType.experience, title: 'Experience', order: 0, entries: [
          SectionEntry(values: {
            'jobTitle': 'Senior Role',
            'company': 'Company Inc.',
            'startDate': '2021',
            'endDate': 'Present',
            'description': 'Key responsibilities and achievements go here.',
          })
        ]),
        ResumeSection(type: SectionType.skills, title: 'Skills', order: 1, entries: [
          SectionEntry(values: {'name': 'Skill A', 'level': 'Advanced'}),
          SectionEntry(values: {'name': 'Skill B', 'level': 'Intermediate'}),
        ]),
      ],
    );

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        child: SizedBox(width: 210, height: 297, child: ResumePreview(resume: preview)),
                      ),
                    ),
                  ),
                  if (locked)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.lock, size: 14, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(def.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                  Text(def.bestFor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
