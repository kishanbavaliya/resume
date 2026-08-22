import 'package:flutter/material.dart';
import '../models/resume.dart';

/// Static config describing a section type: title, icon and its fields.
/// This single source of truth drives the generic section editor,
/// preview renderer and PDF generator so we don't need a bespoke
/// screen per section type (Experience, Education, Awards, ... all
/// share the same engine).
class SectionConfig {
  final SectionType type;
  final String defaultTitle;
  final IconData icon;
  final List<FieldDef> fields;
  final String primaryField; // used as the entry's headline
  final String secondaryField; // used as the entry's subtitle

  const SectionConfig({
    required this.type,
    required this.defaultTitle,
    required this.icon,
    required this.fields,
    required this.primaryField,
    required this.secondaryField,
  });
}

final Map<SectionType, SectionConfig> kSectionConfigs = {
  SectionType.experience: const SectionConfig(
    type: SectionType.experience,
    defaultTitle: 'Experience',
    icon: Icons.work_outline,
    primaryField: 'jobTitle',
    secondaryField: 'company',
    fields: [
      FieldDef(key: 'jobTitle', label: 'Job Title', required: true),
      FieldDef(key: 'company', label: 'Company Name', required: true),
      FieldDef(key: 'location', label: 'Location'),
      FieldDef(key: 'startDate', label: 'Start Date', kind: FieldKind.date),
      FieldDef(key: 'endDate', label: 'End Date', kind: FieldKind.date),
      FieldDef(key: 'current', label: 'Current Job', kind: FieldKind.checkbox),
      FieldDef(
          key: 'description',
          label: 'Description / Responsibilities / Achievements',
          kind: FieldKind.longText),
    ],
  ),
  SectionType.education: const SectionConfig(
    type: SectionType.education,
    defaultTitle: 'Education',
    icon: Icons.school_outlined,
    primaryField: 'degree',
    secondaryField: 'institution',
    fields: [
      FieldDef(key: 'degree', label: 'Degree', required: true),
      FieldDef(key: 'institution', label: 'Institution', required: true),
      FieldDef(key: 'location', label: 'Location'),
      FieldDef(key: 'startDate', label: 'Start Date', kind: FieldKind.date),
      FieldDef(key: 'endDate', label: 'End Date', kind: FieldKind.date),
      FieldDef(key: 'grade', label: 'Grade / GPA'),
      FieldDef(key: 'description', label: 'Description', kind: FieldKind.longText),
    ],
  ),
  SectionType.skills: const SectionConfig(
    type: SectionType.skills,
    defaultTitle: 'Skills',
    icon: Icons.bolt_outlined,
    primaryField: 'name',
    secondaryField: 'level',
    fields: [
      FieldDef(key: 'name', label: 'Skill', required: true),
      FieldDef(key: 'category', label: 'Category (Technical/Soft/Programming/Software/Language/Management/Other)'),
      FieldDef(key: 'level', label: 'Level (Beginner/Intermediate/Advanced/Expert)'),
    ],
  ),
  SectionType.projects: const SectionConfig(
    type: SectionType.projects,
    defaultTitle: 'Projects',
    icon: Icons.rocket_launch_outlined,
    primaryField: 'name',
    secondaryField: 'role',
    fields: [
      FieldDef(key: 'name', label: 'Project Name', required: true),
      FieldDef(key: 'role', label: 'Role'),
      FieldDef(key: 'description', label: 'Description', kind: FieldKind.longText),
      FieldDef(key: 'technologies', label: 'Technologies / Tools'),
      FieldDef(key: 'startDate', label: 'Start Date', kind: FieldKind.date),
      FieldDef(key: 'endDate', label: 'End Date', kind: FieldKind.date),
      FieldDef(key: 'projectUrl', label: 'Project URL'),
      FieldDef(key: 'githubUrl', label: 'GitHub URL'),
    ],
  ),
  SectionType.certifications: const SectionConfig(
    type: SectionType.certifications,
    defaultTitle: 'Certifications',
    icon: Icons.workspace_premium_outlined,
    primaryField: 'name',
    secondaryField: 'organization',
    fields: [
      FieldDef(key: 'name', label: 'Certificate Name', required: true),
      FieldDef(key: 'organization', label: 'Issuing Organization'),
      FieldDef(key: 'issueDate', label: 'Issue Date', kind: FieldKind.date),
      FieldDef(key: 'expiryDate', label: 'Expiration Date', kind: FieldKind.date),
      FieldDef(key: 'credentialId', label: 'Credential ID'),
      FieldDef(key: 'credentialUrl', label: 'Credential URL'),
    ],
  ),
  SectionType.languages: const SectionConfig(
    type: SectionType.languages,
    defaultTitle: 'Languages',
    icon: Icons.language_outlined,
    primaryField: 'language',
    secondaryField: 'proficiency',
    fields: [
      FieldDef(key: 'language', label: 'Language', required: true),
      FieldDef(
          key: 'proficiency',
          label: 'Proficiency (Basic/Conversational/Intermediate/Advanced/Fluent/Native)'),
    ],
  ),
  SectionType.achievements: const SectionConfig(
    type: SectionType.achievements,
    defaultTitle: 'Achievements',
    icon: Icons.emoji_events_outlined,
    primaryField: 'title',
    secondaryField: 'date',
    fields: [
      FieldDef(key: 'title', label: 'Achievement Title', required: true),
      FieldDef(key: 'description', label: 'Description', kind: FieldKind.longText),
      FieldDef(key: 'date', label: 'Date', kind: FieldKind.date),
    ],
  ),
  SectionType.awards: const SectionConfig(
    type: SectionType.awards,
    defaultTitle: 'Awards',
    icon: Icons.military_tech_outlined,
    primaryField: 'name',
    secondaryField: 'organization',
    fields: [
      FieldDef(key: 'name', label: 'Award Name', required: true),
      FieldDef(key: 'organization', label: 'Organization'),
      FieldDef(key: 'date', label: 'Date', kind: FieldKind.date),
      FieldDef(key: 'description', label: 'Description', kind: FieldKind.longText),
    ],
  ),
  SectionType.volunteer: const SectionConfig(
    type: SectionType.volunteer,
    defaultTitle: 'Volunteer Experience',
    icon: Icons.volunteer_activism_outlined,
    primaryField: 'position',
    secondaryField: 'organization',
    fields: [
      FieldDef(key: 'organization', label: 'Organization', required: true),
      FieldDef(key: 'position', label: 'Position'),
      FieldDef(key: 'location', label: 'Location'),
      FieldDef(key: 'startDate', label: 'Start Date', kind: FieldKind.date),
      FieldDef(key: 'endDate', label: 'End Date', kind: FieldKind.date),
      FieldDef(key: 'description', label: 'Description', kind: FieldKind.longText),
    ],
  ),
  SectionType.publications: const SectionConfig(
    type: SectionType.publications,
    defaultTitle: 'Publications',
    icon: Icons.menu_book_outlined,
    primaryField: 'title',
    secondaryField: 'publisher',
    fields: [
      FieldDef(key: 'title', label: 'Publication Title', required: true),
      FieldDef(key: 'publisher', label: 'Publisher'),
      FieldDef(key: 'date', label: 'Date', kind: FieldKind.date),
      FieldDef(key: 'url', label: 'URL'),
      FieldDef(key: 'description', label: 'Description', kind: FieldKind.longText),
    ],
  ),
  SectionType.interests: const SectionConfig(
    type: SectionType.interests,
    defaultTitle: 'Interests',
    icon: Icons.favorite_border,
    primaryField: 'name',
    secondaryField: '',
    fields: [
      FieldDef(key: 'name', label: 'Interest', required: true),
    ],
  ),
  SectionType.references: const SectionConfig(
    type: SectionType.references,
    defaultTitle: 'References',
    icon: Icons.contact_page_outlined,
    primaryField: 'name',
    secondaryField: 'company',
    fields: [
      FieldDef(key: 'name', label: 'Name', required: true),
      FieldDef(key: 'position', label: 'Position'),
      FieldDef(key: 'company', label: 'Company'),
      FieldDef(key: 'email', label: 'Email'),
      FieldDef(key: 'phone', label: 'Phone'),
      FieldDef(key: 'relationship', label: 'Relationship'),
    ],
  ),
  SectionType.custom: const SectionConfig(
    type: SectionType.custom,
    defaultTitle: 'Custom Section',
    icon: Icons.dashboard_customize_outlined,
    primaryField: 'entryTitle',
    secondaryField: 'date',
    fields: [
      FieldDef(key: 'entryTitle', label: 'Entry Title', required: true),
      FieldDef(key: 'description', label: 'Description', kind: FieldKind.longText),
      FieldDef(key: 'date', label: 'Date', kind: FieldKind.date),
    ],
  ),
};

/// Default order & set of sections for a brand-new resume.
List<ResumeSection> defaultSections() {
  const order = [
    SectionType.experience,
    SectionType.education,
    SectionType.skills,
    SectionType.projects,
    SectionType.certifications,
    SectionType.languages,
    SectionType.achievements,
  ];
  return [
    for (var i = 0; i < order.length; i++)
      ResumeSection(
        type: order[i],
        title: kSectionConfigs[order[i]]!.defaultTitle,
        order: i,
        visible: i < 4, // start with core sections visible
      ),
  ];
}

/// All section types not included by default, for "Add Section".
List<SectionType> addableSectionTypes(Resume resume) {
  final existing = resume.sections.map((s) => s.type).toSet();
  return SectionType.values
      .where((t) => t != SectionType.summary)
      .where((t) => t == SectionType.custom || !existing.contains(t))
      .toList();
}

const List<String> professionCategories = [
  'Software Developer',
  'Web Developer',
  'UI/UX Designer',
  'Accountant',
  'Teacher',
  'Nurse',
  'Doctor',
  'Sales Executive',
  'Marketing Manager',
  'Graphic Designer',
  'Data Analyst',
  'Project Manager',
  'Customer Support',
  'HR',
  'Business Analyst',
  'Student',
];

/// Predefined professional-summary examples by profession (feature #5).
const Map<String, String> summaryExamples = {
  'Software Developer':
      'Detail-oriented Software Developer with experience building scalable web and mobile applications. Skilled in writing clean, maintainable code and collaborating with cross-functional teams to ship reliable products on time.',
  'Accountant':
      'Meticulous Accountant with a strong background in financial reporting, reconciliation, and budgeting. Proven record of maintaining accurate records and improving reporting efficiency.',
  'Teacher':
      'Passionate Teacher dedicated to creating engaging lesson plans and fostering a supportive classroom environment that helps students reach their full potential.',
  'Designer':
      'Creative Designer with an eye for detail and a strong portfolio of visual and digital design work, focused on delivering user-centered, on-brand experiences.',
  'Marketing':
      'Results-driven Marketing professional experienced in campaign planning, content strategy, and performance analysis to grow brand awareness and revenue.',
  'Sales':
      'Motivated Sales professional with a track record of exceeding targets, building client relationships, and driving revenue growth.',
  'Business':
      'Analytical Business professional experienced in process improvement, stakeholder communication, and data-driven decision making.',
  'Student':
      'Motivated student pursuing a degree with hands-on project experience and a strong foundation in problem-solving and teamwork, eager to apply skills in a real-world role.',
  'Healthcare':
      'Compassionate healthcare professional committed to patient care, safety, and working collaboratively within clinical teams.',
  'Engineering':
      'Analytical Engineer with hands-on experience designing, testing, and optimizing solutions to real-world technical problems.',
};

/// Job-specific section suggestions (feature #34) — no backend needed.
const Map<String, List<String>> jobSuggestedSections = {
  'Software Developer': ['Experience', 'Projects', 'Skills', 'Education', 'Certifications'],
  'Web Developer': ['Projects', 'Skills', 'Experience', 'Education'],
  'UI/UX Designer': ['Projects', 'Skills', 'Experience', 'Education', 'Interests'],
  'Accountant': ['Experience', 'Education', 'Certifications', 'Skills'],
  'Teacher': ['Experience', 'Education', 'Certifications', 'Achievements'],
  'Nurse': ['Experience', 'Education', 'Certifications', 'Languages'],
  'Doctor': ['Education', 'Certifications', 'Experience', 'Publications'],
  'Sales Executive': ['Experience', 'Achievements', 'Skills', 'Education'],
  'Marketing Manager': ['Experience', 'Projects', 'Skills', 'Achievements'],
  'Graphic Designer': ['Projects', 'Skills', 'Experience', 'Education'],
  'Data Analyst': ['Skills', 'Projects', 'Experience', 'Certifications'],
  'Project Manager': ['Experience', 'Certifications', 'Skills', 'Achievements'],
  'Customer Support': ['Experience', 'Skills', 'Languages', 'Education'],
  'HR': ['Experience', 'Education', 'Skills', 'Certifications'],
  'Business Analyst': ['Experience', 'Skills', 'Projects', 'Certifications'],
  'Student': ['Education', 'Projects', 'Skills', 'Achievements', 'Volunteer Experience'],
};

/// Builds a fully pre-filled sample resume (feature #33) so users don't
/// have to start from a blank page.
Resume buildSampleResume() {
  final r = Resume(
    title: 'Sample Resume',
    summary: summaryExamples['Software Developer']!,
  );
  r.personalInfo
    ..fullName = 'Alex Morgan'
    ..jobTitle = 'Software Developer'
    ..email = 'alex.morgan@email.com'
    ..phone = '+1 555 123 4567'
    ..city = 'Austin'
    ..state = 'TX'
    ..country = 'USA'
    ..linkedin = 'linkedin.com/in/alexmorgan'
    ..github = 'github.com/alexmorgan';

  final sections = defaultSections();
  for (final s in sections) {
    s.visible = true;
  }

  sections.firstWhere((s) => s.type == SectionType.experience).entries.addAll([
    SectionEntry(values: {
      'jobTitle': 'Software Developer',
      'company': 'Tech Solutions Inc.',
      'location': 'Austin, TX',
      'startDate': 'Jan 2022',
      'endDate': 'Present',
      'current': 'true',
      'description':
          'Built and maintained REST APIs used by 50k+ users. Improved page load time by 35% through performance optimization. Collaborated with design and QA teams in an agile workflow.',
    }),
  ]);
  sections.firstWhere((s) => s.type == SectionType.education).entries.add(
        SectionEntry(values: {
          'degree': "Bachelor's in Computer Science",
          'institution': 'University of Texas',
          'location': 'Austin, TX',
          'startDate': '2018',
          'endDate': '2022',
          'grade': '3.7 GPA',
        }),
      );
  sections.firstWhere((s) => s.type == SectionType.skills).entries.addAll([
    SectionEntry(values: {'name': 'Flutter', 'category': 'Programming', 'level': 'Advanced'}),
    SectionEntry(values: {'name': 'Dart', 'category': 'Programming', 'level': 'Advanced'}),
    SectionEntry(values: {'name': 'Git', 'category': 'Software', 'level': 'Intermediate'}),
    SectionEntry(values: {'name': 'Teamwork', 'category': 'Soft Skills', 'level': 'Expert'}),
  ]);
  sections.firstWhere((s) => s.type == SectionType.projects).entries.add(
        SectionEntry(values: {
          'name': 'Resume Maker App',
          'role': 'Lead Developer',
          'description': 'Cross-platform resume builder with offline PDF export.',
          'technologies': 'Flutter, Dart',
        }),
      );
  sections.firstWhere((s) => s.type == SectionType.languages).entries.add(
        SectionEntry(values: {'language': 'English', 'proficiency': 'Native'}),
      );

  r.sections = sections;
  return r;
}

/// Offline resume-writing tips (feature #32).
class TipGroup {
  final String title;
  final List<String> tips;
  const TipGroup(this.title, this.tips);
}

const List<TipGroup> resumeTips = [
  TipGroup('General Tips', [
    'Keep your resume concise — ideally one page for early-career roles.',
    'Use clear section headings so it is easy to scan.',
    'Highlight achievements with numbers where possible (e.g. "increased sales by 20%").',
    'Use a professional email address.',
    'Avoid unnecessary personal information.',
  ]),
  TipGroup('Fresher / Student Resume Tips', [
    'Lead with Education and Projects if you lack work experience.',
    'Include relevant coursework, academic projects, and internships.',
    'List extracurricular activities that show leadership or teamwork.',
  ]),
  TipGroup('Developer Resume Tips', [
    'List your tech stack clearly under Skills.',
    'Link to GitHub and live project demos.',
    'Describe impact, not just responsibilities ("reduced load time by 40%").',
  ]),
  TipGroup('Marketing Resume Tips', [
    'Quantify campaign results (reach, conversion, ROI).',
    'Show a mix of creative and analytical skills.',
  ]),
  TipGroup('Accountant Resume Tips', [
    'Highlight accuracy, compliance, and relevant software (Excel, QuickBooks, SAP).',
    'Mention certifications like CPA if applicable.',
  ]),
  TipGroup('Teacher Resume Tips', [
    'Emphasize classroom management and curriculum development experience.',
    'List certifications and grade levels / subjects taught.',
  ]),
];
