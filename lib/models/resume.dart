import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// The type of a resume section. Personal info & summary are handled
/// specially (fixed, always present); everything else is a generic
/// repeatable section driven by [SectionType] + field config.
enum SectionType {
  summary,
  experience,
  education,
  skills,
  projects,
  certifications,
  languages,
  achievements,
  awards,
  volunteer,
  publications,
  interests,
  references,
  custom,
}

/// One field within a section entry (e.g. "Job Title" text field).
class FieldDef {
  final String key;
  final String label;
  final FieldKind kind;
  final bool required;
  final String? hint;

  const FieldDef({
    required this.key,
    required this.label,
    this.kind = FieldKind.text,
    this.required = false,
    this.hint,
  });
}

enum FieldKind { text, longText, date, checkbox, dropdown }

/// A single repeatable item inside a section, e.g. one job in Experience.
class SectionEntry {
  String id;
  Map<String, String> values;

  SectionEntry({String? id, Map<String, String>? values})
      : id = id ?? _uuid.v4(),
        values = values ?? {};

  SectionEntry copy() => SectionEntry(id: _uuid.v4(), values: Map.of(values));

  Map<String, dynamic> toJson() => {'id': id, 'values': values};

  factory SectionEntry.fromJson(Map<String, dynamic> json) => SectionEntry(
        id: json['id'] as String?,
        values: Map<String, String>.from(json['values'] as Map? ?? {}),
      );
}

/// A section within a resume (Experience, Education, Skills, ...).
/// Order + visibility are user-controlled ("Resume Section Management").
class ResumeSection {
  String id;
  SectionType type;
  String title; // editable, esp. for custom sections
  bool visible;
  int order;
  List<SectionEntry> entries;

  ResumeSection({
    String? id,
    required this.type,
    required this.title,
    this.visible = true,
    required this.order,
    List<SectionEntry>? entries,
  })  : id = id ?? _uuid.v4(),
        entries = entries ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'visible': visible,
        'order': order,
        'entries': entries.map((e) => e.toJson()).toList(),
      };

  factory ResumeSection.fromJson(Map<String, dynamic> json) => ResumeSection(
        id: json['id'] as String?,
        type: SectionType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => SectionType.custom,
        ),
        title: json['title'] as String? ?? '',
        visible: json['visible'] as bool? ?? true,
        order: json['order'] as int? ?? 0,
        entries: (json['entries'] as List? ?? [])
            .map((e) => SectionEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class PersonalInfo {
  String fullName;
  String jobTitle;
  String photoPath; // local file path, empty = no photo
  String phone;
  String email;
  String address;
  String city;
  String state;
  String country;
  String zip;
  String website;
  String linkedin;
  String github;
  String portfolio;
  String otherLink;

  bool showPhoto;
  bool showAddress;
  bool showSocialLinks;

  PersonalInfo({
    this.fullName = '',
    this.jobTitle = '',
    this.photoPath = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.country = '',
    this.zip = '',
    this.website = '',
    this.linkedin = '',
    this.github = '',
    this.portfolio = '',
    this.otherLink = '',
    this.showPhoto = true,
    this.showAddress = true,
    this.showSocialLinks = true,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'jobTitle': jobTitle,
        'photoPath': photoPath,
        'phone': phone,
        'email': email,
        'address': address,
        'city': city,
        'state': state,
        'country': country,
        'zip': zip,
        'website': website,
        'linkedin': linkedin,
        'github': github,
        'portfolio': portfolio,
        'otherLink': otherLink,
        'showPhoto': showPhoto,
        'showAddress': showAddress,
        'showSocialLinks': showSocialLinks,
      };

  factory PersonalInfo.fromJson(Map<String, dynamic> json) => PersonalInfo(
        fullName: json['fullName'] ?? '',
        jobTitle: json['jobTitle'] ?? '',
        photoPath: json['photoPath'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'] ?? '',
        address: json['address'] ?? '',
        city: json['city'] ?? '',
        state: json['state'] ?? '',
        country: json['country'] ?? '',
        zip: json['zip'] ?? '',
        website: json['website'] ?? '',
        linkedin: json['linkedin'] ?? '',
        github: json['github'] ?? '',
        portfolio: json['portfolio'] ?? '',
        otherLink: json['otherLink'] ?? '',
        showPhoto: json['showPhoto'] ?? true,
        showAddress: json['showAddress'] ?? true,
        showSocialLinks: json['showSocialLinks'] ?? true,
      );
}

/// Template + styling choices for a resume ("Editable Resume Templates",
/// "Template Customization").
class TemplateSettings {
  String templateId; // e.g. 'classic_professional'
  String colorId; // e.g. 'blue'
  String fontId; // e.g. 'modern'
  bool showIcons;
  bool showSkillBars;
  bool atsMode;

  TemplateSettings({
    this.templateId = 'classic_professional',
    this.colorId = 'blue',
    this.fontId = 'modern',
    this.showIcons = true,
    this.showSkillBars = true,
    this.atsMode = false,
  });

  Map<String, dynamic> toJson() => {
        'templateId': templateId,
        'colorId': colorId,
        'fontId': fontId,
        'showIcons': showIcons,
        'showSkillBars': showSkillBars,
        'atsMode': atsMode,
      };

  factory TemplateSettings.fromJson(Map<String, dynamic> json) =>
      TemplateSettings(
        templateId: json['templateId'] ?? 'classic_professional',
        colorId: json['colorId'] ?? 'blue',
        fontId: json['fontId'] ?? 'modern',
        showIcons: json['showIcons'] ?? true,
        showSkillBars: json['showSkillBars'] ?? true,
        atsMode: json['atsMode'] ?? false,
      );
}

class Resume {
  String id;
  String title; // e.g. "Software Developer Resume"
  PersonalInfo personalInfo;
  String summary;
  List<ResumeSection> sections;
  TemplateSettings templateSettings;
  DateTime createdAt;
  DateTime updatedAt;

  Resume({
    String? id,
    this.title = 'Untitled Resume',
    PersonalInfo? personalInfo,
    this.summary = '',
    List<ResumeSection>? sections,
    TemplateSettings? templateSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? _uuid.v4(),
        personalInfo = personalInfo ?? PersonalInfo(),
        sections = sections ?? [],
        templateSettings = templateSettings ?? TemplateSettings(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Resume copyWith({String? title}) {
    return Resume(
      id: _uuid.v4(),
      title: title ?? '${this.title} (Copy)',
      personalInfo: PersonalInfo.fromJson(personalInfo.toJson()),
      summary: summary,
      sections: sections
          .map((s) => ResumeSection.fromJson(s.toJson()))
          .toList(),
      templateSettings: TemplateSettings.fromJson(templateSettings.toJson()),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Resume Completion Score (0-100) — feature #31.
  int completionScore() {
    int total = 0;
    int done = 0;

    total += 3;
    if (personalInfo.fullName.trim().isNotEmpty) done++;
    if (personalInfo.email.trim().isNotEmpty) done++;
    if (personalInfo.phone.trim().isNotEmpty) done++;

    total += 1;
    if (summary.trim().length > 20) done++;

    total += 1;
    if (sectionByType(SectionType.experience)?.entries.isNotEmpty ?? false) {
      done++;
    }

    total += 1;
    if (sectionByType(SectionType.education)?.entries.isNotEmpty ?? false) {
      done++;
    }

    total += 1;
    if (sectionByType(SectionType.skills)?.entries.isNotEmpty ?? false) {
      done++;
    }

    total += 1;
    if (personalInfo.linkedin.trim().isNotEmpty ||
        personalInfo.website.trim().isNotEmpty) {
      done++;
    }

    total += 1;
    if (sectionByType(SectionType.projects)?.entries.isNotEmpty ?? false) {
      done++;
    }

    return ((done / total) * 100).round();
  }

  List<String> completionSuggestions() {
    final s = <String>[];
    if (summary.trim().length <= 20) s.add('Add a professional summary');
    if (!(sectionByType(SectionType.skills)?.entries.isNotEmpty ?? false)) {
      s.add('Add your skills');
    }
    if (!(sectionByType(SectionType.experience)?.entries.isNotEmpty ??
        false)) {
      s.add('Add work experience');
    }
    if (personalInfo.linkedin.trim().isEmpty) s.add('Add your LinkedIn');
    if (!(sectionByType(SectionType.projects)?.entries.isNotEmpty ?? false)) {
      s.add('Add a project');
    }
    return s;
  }

  ResumeSection? sectionByType(SectionType type) {
    try {
      return sections.firstWhere((s) => s.type == type);
    } catch (_) {
      return null;
    }
  }

  List<ResumeSection> get visibleSectionsSorted {
    final list = sections.where((s) => s.visible).toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'personalInfo': personalInfo.toJson(),
        'summary': summary,
        'sections': sections.map((s) => s.toJson()).toList(),
        'templateSettings': templateSettings.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Resume.fromJson(Map<String, dynamic> json) => Resume(
        id: json['id'] as String?,
        title: json['title'] ?? 'Untitled Resume',
        personalInfo: PersonalInfo.fromJson(
            json['personalInfo'] as Map<String, dynamic>? ?? {}),
        summary: json['summary'] ?? '',
        sections: (json['sections'] as List? ?? [])
            .map((s) => ResumeSection.fromJson(s as Map<String, dynamic>))
            .toList(),
        templateSettings: TemplateSettings.fromJson(
            json['templateSettings'] as Map<String, dynamic>? ?? {}),
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ??
            DateTime.now(),
      );
}
