import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/section_definitions.dart';
import '../models/resume.dart';
import '../models/template.dart' as tpl;

/// Renders a [Resume] on-screen exactly following its TemplateSettings.
/// This is the single "source of truth" for what a template looks like;
/// lib/pdf/pdf_generator.dart mirrors this layout for the exported PDF.
class ResumePreview extends StatelessWidget {
  final Resume resume;
  const ResumePreview({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    final def = tpl.templateById(resume.templateSettings.templateId);
    final accent = tpl.colorById(resume.templateSettings.colorId);
    final font = tpl.fontById(resume.templateSettings.fontId);

    return AspectRatio(
      aspectRatio: 210 / 297, // A4
      child: Container(
        color: Colors.white,
        child: def.engine == tpl.LayoutEngine.sidebar
            ? _SidebarLayout(resume: resume, def: def, accent: accent, font: font)
            : _SingleLayout(resume: resume, def: def, accent: accent, font: font),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Shared building blocks
// ---------------------------------------------------------------------

TextStyle _heading(tpl.FontOption font, {double size = 11, Color? color, FontWeight? weight}) {
  return GoogleFonts.getFont(font.headingFont,
      fontSize: size, fontWeight: weight ?? FontWeight.w700, color: color ?? Colors.black87);
}

TextStyle _body(tpl.FontOption font, {double size = 8.5, Color? color, FontWeight? weight}) {
  return GoogleFonts.getFont(font.bodyFont,
      fontSize: size, fontWeight: weight ?? FontWeight.normal, color: color ?? Colors.black87);
}

String _entryDateRange(SectionEntry e) {
  final start = e.values['startDate'] ?? '';
  final isCurrent = e.values['current'] == 'true';
  final end = isCurrent ? 'Present' : (e.values['endDate'] ?? '');
  if (start.isEmpty && end.isEmpty) return '';
  return '$start${end.isNotEmpty ? ' - $end' : ''}';
}

Widget _sectionHeading(String title, Color accent, tpl.FontOption font, {bool line = true}) {
  return Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 3),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(),
            style: _heading(font, size: 9.5, color: accent, weight: FontWeight.w700)
                .copyWith(letterSpacing: 0.6)),
        if (line)
          Container(height: 1, margin: const EdgeInsets.only(top: 2), color: accent.withOpacity(0.5)),
      ],
    ),
  );
}

/// Generic renderer for one section's entries — used by both layouts.
Widget _sectionBody(ResumeSection section, Color accent, tpl.FontOption font,
    {bool showBars = true}) {
  final cfg = kSectionConfigs[section.type];
  if (cfg == null || section.entries.isEmpty) return const SizedBox.shrink();

  if (section.type == SectionType.skills) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: section.entries.map((e) {
        final name = e.values['name'] ?? '';
        final level = e.values['level'] ?? '';
        if (showBars && level.isNotEmpty) {
          final pct = switch (level) {
            'Beginner' => 0.35,
            'Intermediate' => 0.6,
            'Advanced' => 0.85,
            'Expert' => 1.0,
            _ => 0.5,
          };
          return SizedBox(
            width: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: _body(font, size: 7.5)),
                const SizedBox(height: 1),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 3,
                    backgroundColor: accent.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation(accent),
                  ),
                ),
              ],
            ),
          );
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(name, style: _body(font, size: 7.5, color: accent)),
        );
      }).toList(),
    );
  }

  if (section.type == SectionType.interests) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: section.entries
          .map((e) => Text('• ${e.values['name'] ?? ''}', style: _body(font, size: 7.5)))
          .toList(),
    );
  }

  if (section.type == SectionType.languages) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: section.entries.map((e) {
        return Text('${e.values['language'] ?? ''} — ${e.values['proficiency'] ?? ''}',
            style: _body(font, size: 7.5));
      }).toList(),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: section.entries.map((e) {
      final primary = e.values[cfg.primaryField] ?? '';
      final secondary =
          cfg.secondaryField.isNotEmpty ? (e.values[cfg.secondaryField] ?? '') : '';
      final dateRange = _entryDateRange(e);
      final desc = e.values['description'] ?? '';
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(primary,
                      style: _body(font, size: 8.5, weight: FontWeight.w700)),
                ),
                if (dateRange.isNotEmpty)
                  Text(dateRange, style: _body(font, size: 7, color: Colors.black54)),
              ],
            ),
            if (secondary.isNotEmpty)
              Text(secondary, style: _body(font, size: 7.5, color: accent)),
            if (desc.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(desc, style: _body(font, size: 7.5)),
              ),
          ],
        ),
      );
    }).toList(),
  );
}

Widget _photoWidget(PersonalInfo info, {double size = 60, bool circle = true}) {
  if (!info.showPhoto || info.photoPath.isEmpty) return const SizedBox.shrink();
  final file = File(info.photoPath);
  final image = file.existsSync()
      ? Image.file(file, width: size, height: size, fit: BoxFit.cover)
      : Container(width: size, height: size, color: Colors.grey.shade300);
  return ClipRRect(
    borderRadius: BorderRadius.circular(circle ? size : 6),
    child: image,
  );
}

List<String> _contactLines(PersonalInfo info, {bool includeAddress = true}) {
  final lines = <String>[];
  if (info.phone.isNotEmpty) lines.add(info.phone);
  if (info.email.isNotEmpty) lines.add(info.email);
  if (includeAddress && info.showAddress) {
    final loc = [info.city, info.state, info.country].where((s) => s.isNotEmpty).join(', ');
    if (loc.isNotEmpty) lines.add(loc);
  }
  if (info.showSocialLinks) {
    if (info.linkedin.isNotEmpty) lines.add(info.linkedin);
    if (info.github.isNotEmpty) lines.add(info.github);
    if (info.website.isNotEmpty) lines.add(info.website);
    if (info.portfolio.isNotEmpty) lines.add(info.portfolio);
  }
  return lines;
}

// ---------------------------------------------------------------------
// Single-column layout (Classic, Minimal, ATS, Executive, Student, Elegant)
// ---------------------------------------------------------------------

class _SingleLayout extends StatelessWidget {
  final Resume resume;
  final tpl.TemplateDef def;
  final Color accent;
  final tpl.FontOption font;
  const _SingleLayout(
      {required this.resume, required this.def, required this.accent, required this.font});

  @override
  Widget build(BuildContext context) {
    final info = resume.personalInfo;
    final ats = resume.templateSettings.atsMode;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!ats) _photoWidget(info, size: def.denseHeader ? 56 : 48),
              if (!ats && info.showPhoto && info.photoPath.isNotEmpty)
                const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(info.fullName.isEmpty ? 'Your Name' : info.fullName,
                        style: _heading(font,
                            size: def.denseHeader ? 20 : 17,
                            color: def.denseHeader ? accent : Colors.black87)),
                    if (info.jobTitle.isNotEmpty)
                      Text(info.jobTitle,
                          style: _body(font, size: 10, color: accent, weight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Wrap(
                      spacing: 10,
                      runSpacing: 2,
                      children: _contactLines(info)
                          .map((l) => Text(l, style: _body(font, size: 7.5, color: Colors.black54)))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(margin: const EdgeInsets.only(top: 8), height: 1.5, color: accent),
          if (resume.summary.trim().isNotEmpty) ...[
            _sectionHeading('Summary', accent, font),
            Text(resume.summary, style: _body(font)),
          ],
          for (final s in resume.visibleSectionsSorted) ...[
            _sectionHeading(s.title, accent, font),
            _sectionBody(s, accent, font, showBars: resume.templateSettings.showSkillBars && !ats),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Sidebar layout (Modern Blue, Creative, Tech, Two Column)
// ---------------------------------------------------------------------

class _SidebarLayout extends StatelessWidget {
  final Resume resume;
  final tpl.TemplateDef def;
  final Color accent;
  final tpl.FontOption font;
  const _SidebarLayout(
      {required this.resume, required this.def, required this.accent, required this.font});

  static const _sidebarTypes = {
    SectionType.skills,
    SectionType.languages,
    SectionType.interests,
    SectionType.certifications,
  };

  @override
  Widget build(BuildContext context) {
    final info = resume.personalInfo;
    final sidebarSections =
        resume.visibleSectionsSorted.where((s) => _sidebarTypes.contains(s.type)).toList();
    final mainSections =
        resume.visibleSectionsSorted.where((s) => !_sidebarTypes.contains(s.type)).toList();

    final sidebar = Container(
      width: 130,
      color: accent,
      padding: const EdgeInsets.all(14),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (info.showPhoto && info.photoPath.isNotEmpty) ...[
              Center(child: _photoWidget(info, size: 64)),
              const SizedBox(height: 10),
            ],
            Text(info.fullName.isEmpty ? 'Your Name' : info.fullName,
                style: _heading(font, size: 13, color: Colors.white)),
            if (info.jobTitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(info.jobTitle,
                    style: _body(font, size: 8, color: Colors.white70, weight: FontWeight.w600)),
              ),
            const SizedBox(height: 8),
            ..._contactLines(info)
                .map((l) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(l, style: _body(font, size: 7, color: Colors.white)),
                    )),
            for (final s in sidebarSections) ...[
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 3),
                child: Text(s.title.toUpperCase(),
                    style: _heading(font, size: 8.5, color: Colors.white)
                        .copyWith(letterSpacing: 0.5)),
              ),
              DefaultTextStyle(
                style: _body(font, size: 7, color: Colors.white),
                child: _sectionBodyLight(s, font),
              ),
            ],
          ],
        ),
      ),
    );

    final main = Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (resume.summary.trim().isNotEmpty) ...[
                _sectionHeading('Summary', accent, font),
                Text(resume.summary, style: _body(font)),
              ],
              for (final s in mainSections) ...[
                _sectionHeading(s.title, accent, font),
                _sectionBody(s, accent, font),
              ],
            ],
          ),
        ),
      ),
    );

    final children = def.sidebarOnLeft ? [sidebar, main] : [main, sidebar];
    return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
  }

  Widget _sectionBodyLight(ResumeSection s, tpl.FontOption font) {
    if (s.type == SectionType.skills) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: s.entries
            .map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text('• ${e.values['name'] ?? ''}'),
                ))
            .toList(),
      );
    }
    if (s.type == SectionType.languages) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: s.entries
            .map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text('${e.values['language'] ?? ''} (${e.values['proficiency'] ?? ''})'),
                ))
            .toList(),
      );
    }
    if (s.type == SectionType.interests) {
      return Wrap(
        spacing: 4,
        runSpacing: 4,
        children: s.entries.map((e) => Text('• ${e.values['name'] ?? ''}')).toList(),
      );
    }
    final cfg = kSectionConfigs[s.type]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: s.entries
          .map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(e.values[cfg.primaryField] ?? ''),
              ))
          .toList(),
    );
  }
}
