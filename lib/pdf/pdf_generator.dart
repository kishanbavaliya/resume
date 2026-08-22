import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../data/section_definitions.dart';
import '../models/resume.dart';
import '../models/template.dart' as tpl;

/// Builds a [pw.Document] that mirrors ResumePreview's on-screen layout.
///
/// Deliberately uses the PDF package's built-in core fonts (Helvetica /
/// Times / Courier) rather than downloaded Google Fonts, so PDF export
/// always works fully offline per the product spec (no network
/// dependency at export time), even though the in-app live preview
/// uses nicer downloaded fonts for a richer editing experience.
class PdfGenerator {
  static Future<pw.Document> build(Resume resume, {String paperSize = 'A4'}) async {
    final doc = pw.Document();
    final def = tpl.templateById(resume.templateSettings.templateId);
    final accent = PdfColor.fromInt(tpl.colorById(resume.templateSettings.colorId).value);
    final fonts = _fontsFor(resume.templateSettings.fontId);
    final page = paperSize == 'Letter' ? PdfPageFormat.letter : PdfPageFormat.a4;

    if (def.engine == tpl.LayoutEngine.sidebar) {
      doc.addPage(pw.Page(
        pageFormat: page,
        margin: pw.EdgeInsets.zero,
        build: (ctx) => _sidebarPage(resume, def, accent, fonts),
      ));
    } else {
      doc.addPage(pw.MultiPage(
        pageFormat: page,
        margin: const pw.EdgeInsets.all(28),
        build: (ctx) => _singlePage(resume, def, accent, fonts),
      ));
    }
    return doc;
  }

  static Future<File> saveToFile(pw.Document doc, String fileName) async {
    final dir = Directory.systemTemp;
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await doc.save());
    return file;
  }
}

class _Fonts {
  final pw.Font regular;
  final pw.Font bold;
  final pw.Font italic;
  _Fonts(this.regular, this.bold, this.italic);
}

_Fonts _fontsFor(String fontId) {
  switch (fontId) {
    case 'classic':
    case 'elegant':
      return _Fonts(pw.Font.times(), pw.Font.timesBold(), pw.Font.timesItalic());
    default:
      return _Fonts(pw.Font.helvetica(), pw.Font.helveticaBold(), pw.Font.helveticaOblique());
  }
}

String _dateRange(SectionEntry e) {
  final start = e.values['startDate'] ?? '';
  final isCurrent = e.values['current'] == 'true';
  final end = isCurrent ? 'Present' : (e.values['endDate'] ?? '');
  if (start.isEmpty && end.isEmpty) return '';
  return '$start${end.isNotEmpty ? ' - $end' : ''}';
}

List<String> _contactLines(PersonalInfo info) {
  final lines = <String>[];
  if (info.phone.isNotEmpty) lines.add(info.phone);
  if (info.email.isNotEmpty) lines.add(info.email);
  if (info.showAddress) {
    final loc = [info.city, info.state, info.country].where((s) => s.isNotEmpty).join(', ');
    if (loc.isNotEmpty) lines.add(loc);
  }
  if (info.showSocialLinks) {
    for (final l in [info.linkedin, info.github, info.website, info.portfolio]) {
      if (l.isNotEmpty) lines.add(l);
    }
  }
  return lines;
}

pw.Widget _pdfSectionHeading(String title, PdfColor accent, _Fonts f) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(top: 10, bottom: 4),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title.toUpperCase(),
            style: pw.TextStyle(font: f.bold, fontSize: 11, color: accent, letterSpacing: 1)),
        pw.Container(
            margin: const pw.EdgeInsets.only(top: 2),
            height: 1,
            color: PdfColor.fromInt(accent.toInt()).shade(0.4)),
      ],
    ),
  );
}

pw.Widget _pdfSectionBody(ResumeSection s, PdfColor accent, _Fonts f) {
  final cfg = kSectionConfigs[s.type];
  if (cfg == null || s.entries.isEmpty) return pw.SizedBox();

  if (s.type == SectionType.skills) {
    return pw.Wrap(
      spacing: 6,
      runSpacing: 6,
      children: s.entries
          .map((e) => pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: pw.BoxDecoration(
                    color: accent.shade(0.85), borderRadius: pw.BorderRadius.circular(8)),
                child: pw.Text(e.values['name'] ?? '',
                    style: pw.TextStyle(font: f.regular, fontSize: 9, color: accent)),
              ))
          .toList(),
    );
  }

  if (s.type == SectionType.interests) {
    return pw.Wrap(
      spacing: 8,
      runSpacing: 4,
      children: s.entries
          .map((e) => pw.Text('• ${e.values['name'] ?? ''}',
              style: pw.TextStyle(font: f.regular, fontSize: 9)))
          .toList(),
    );
  }

  if (s.type == SectionType.languages) {
    return pw.Wrap(
      spacing: 14,
      runSpacing: 4,
      children: s.entries
          .map((e) => pw.Text('${e.values['language'] ?? ''} — ${e.values['proficiency'] ?? ''}',
              style: pw.TextStyle(font: f.regular, fontSize: 9)))
          .toList(),
    );
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: s.entries.map((e) {
      final primary = e.values[cfg.primaryField] ?? '';
      final secondary = cfg.secondaryField.isNotEmpty ? (e.values[cfg.secondaryField] ?? '') : '';
      final dateRange = _dateRange(e);
      final desc = e.values['description'] ?? '';
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 7),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(primary, style: pw.TextStyle(font: f.bold, fontSize: 10)),
                if (dateRange.isNotEmpty)
                  pw.Text(dateRange,
                      style: pw.TextStyle(font: f.italic, fontSize: 8, color: PdfColors.grey700)),
              ],
            ),
            if (secondary.isNotEmpty)
              pw.Text(secondary, style: pw.TextStyle(font: f.regular, fontSize: 9, color: accent)),
            if (desc.isNotEmpty)
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 2),
                child: pw.Text(desc, style: pw.TextStyle(font: f.regular, fontSize: 9)),
              ),
          ],
        ),
      );
    }).toList(),
  );
}

List<pw.Widget> _singlePage(Resume resume, tpl.TemplateDef def, PdfColor accent, _Fonts f) {
  final info = resume.personalInfo;
  return [
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (info.showPhoto && info.photoPath.isNotEmpty && File(info.photoPath).existsSync())
          pw.Container(
            margin: const pw.EdgeInsets.only(right: 14),
            width: 60,
            height: 60,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              image: pw.DecorationImage(
                  image: pw.MemoryImage(File(info.photoPath).readAsBytesSync()), fit: pw.BoxFit.cover),
            ),
          ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(info.fullName.isEmpty ? 'Your Name' : info.fullName,
                  style: pw.TextStyle(font: f.bold, fontSize: def.denseHeader ? 24 : 20)),
              if (info.jobTitle.isNotEmpty)
                pw.Text(info.jobTitle,
                    style: pw.TextStyle(font: f.regular, fontSize: 12, color: accent)),
              pw.SizedBox(height: 4),
              pw.Wrap(
                spacing: 12,
                runSpacing: 2,
                children: _contactLines(info)
                    .map((l) =>
                        pw.Text(l, style: pw.TextStyle(font: f.regular, fontSize: 9, color: PdfColors.grey700)))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    ),
    pw.Container(margin: const pw.EdgeInsets.only(top: 8), height: 1.5, color: accent),
    if (resume.summary.trim().isNotEmpty) ...[
      _pdfSectionHeading('Summary', accent, f),
      pw.Text(resume.summary, style: pw.TextStyle(font: f.regular, fontSize: 9.5)),
    ],
    for (final s in resume.visibleSectionsSorted) ...[
      _pdfSectionHeading(s.title, accent, f),
      _pdfSectionBody(s, accent, f),
    ],
  ];
}

pw.Widget _sidebarPage(Resume resume, tpl.TemplateDef def, PdfColor accent, _Fonts f) {
  final info = resume.personalInfo;
  const sidebarTypes = {
    SectionType.skills,
    SectionType.languages,
    SectionType.interests,
    SectionType.certifications,
  };
  final sidebarSections =
      resume.visibleSectionsSorted.where((s) => sidebarTypes.contains(s.type)).toList();
  final mainSections =
      resume.visibleSectionsSorted.where((s) => !sidebarTypes.contains(s.type)).toList();

  final sidebar = pw.Container(
    width: 170,
    color: accent,
    padding: const pw.EdgeInsets.all(18),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (info.showPhoto && info.photoPath.isNotEmpty && File(info.photoPath).existsSync())
          pw.Center(
            child: pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 10),
              width: 80,
              height: 80,
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                image: pw.DecorationImage(
                    image: pw.MemoryImage(File(info.photoPath).readAsBytesSync()),
                    fit: pw.BoxFit.cover),
              ),
            ),
          ),
        pw.Text(info.fullName.isEmpty ? 'Your Name' : info.fullName,
            style: pw.TextStyle(font: f.bold, fontSize: 16, color: PdfColors.white)),
        if (info.jobTitle.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 2),
            child: pw.Text(info.jobTitle,
                style: pw.TextStyle(font: f.regular, fontSize: 9, color: PdfColors.white)),
          ),
        pw.SizedBox(height: 10),
        for (final l in _contactLines(info))
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Text(l, style: pw.TextStyle(font: f.regular, fontSize: 8.5, color: PdfColors.white)),
          ),
        for (final s in sidebarSections) ...[
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 12, bottom: 4),
            child: pw.Text(s.title.toUpperCase(),
                style: pw.TextStyle(font: f.bold, fontSize: 10, color: PdfColors.white)),
          ),
          ..._sidebarEntryLines(s, f),
        ],
      ],
    ),
  );

  final main = pw.Expanded(
    child: pw.Container(
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (resume.summary.trim().isNotEmpty) ...[
            _pdfSectionHeading('Summary', accent, f),
            pw.Text(resume.summary, style: pw.TextStyle(font: f.regular, fontSize: 9.5)),
          ],
          for (final s in mainSections) ...[
            _pdfSectionHeading(s.title, accent, f),
            _pdfSectionBody(s, accent, f),
          ],
        ],
      ),
    ),
  );

  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: def.sidebarOnLeft ? [sidebar, main] : [main, sidebar],
  );
}

List<pw.Widget> _sidebarEntryLines(ResumeSection s, _Fonts f) {
  final style = pw.TextStyle(font: f.regular, fontSize: 8.5, color: PdfColors.white);
  if (s.type == SectionType.languages) {
    return s.entries
        .map((e) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 3),
              child: pw.Text('${e.values['language'] ?? ''} (${e.values['proficiency'] ?? ''})',
                  style: style),
            ))
        .toList();
  }
  final cfg = kSectionConfigs[s.type]!;
  return s.entries
      .map((e) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3),
            child: pw.Text('• ${e.values[cfg.primaryField] ?? ''}', style: style),
          ))
      .toList();
}
