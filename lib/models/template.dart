import 'package:flutter/material.dart';

/// Two underlying layout engines power all 10 named templates:
/// - single: one column, header on top (Classic, Minimal, ATS, Executive,
///   Student, Elegant)
/// - sidebar: colored side column for contact/skills/photo (Modern Blue,
///   Creative, Tech, Two Column)
enum LayoutEngine { single, sidebar }

class TemplateDef {
  final String id;
  final String name;
  final String description;
  final String bestFor;
  final LayoutEngine engine;
  final String defaultColorId;
  final String defaultFontId;
  final bool isPremium;
  final bool denseHeader; // executive-style bold header
  final bool sidebarOnLeft;

  const TemplateDef({
    required this.id,
    required this.name,
    required this.description,
    required this.bestFor,
    required this.engine,
    this.defaultColorId = 'blue',
    this.defaultFontId = 'modern',
    this.isPremium = false,
    this.denseHeader = false,
    this.sidebarOnLeft = true,
  });
}

const List<TemplateDef> kTemplates = [
  TemplateDef(
    id: 'classic_professional',
    name: 'Classic Professional',
    description: 'Traditional, clean, ATS-friendly, single column.',
    bestFor: 'Corporate, Accounting, Finance, Administration',
    engine: LayoutEngine.single,
    defaultColorId: 'black',
    defaultFontId: 'classic',
  ),
  TemplateDef(
    id: 'modern_blue',
    name: 'Modern Blue',
    description: 'Modern, blue accent, two-column layout.',
    bestFor: 'IT, Marketing, Business, Professionals',
    engine: LayoutEngine.sidebar,
    defaultColorId: 'blue',
    defaultFontId: 'modern',
    isPremium: true,
  ),
  TemplateDef(
    id: 'minimal',
    name: 'Minimal',
    description: 'Very clean, lots of whitespace, simple typography.',
    bestFor: 'Professionals, Executives, Corporate jobs',
    engine: LayoutEngine.single,
    defaultColorId: 'dark_gray',
    defaultFontId: 'clean',
  ),
  TemplateDef(
    id: 'creative',
    name: 'Creative',
    description: 'Color accent, modern sections, visual skills.',
    bestFor: 'Designers, Creatives, Content creators, Marketing',
    engine: LayoutEngine.sidebar,
    defaultColorId: 'purple',
    defaultFontId: 'modern',
    isPremium: true,
    sidebarOnLeft: false,
  ),
  TemplateDef(
    id: 'ats_friendly',
    name: 'ATS Friendly',
    description: 'Simple, single column, standard headings, ATS-safe.',
    bestFor: 'Online job applications, Corporate applications, Software jobs',
    engine: LayoutEngine.single,
    defaultColorId: 'black',
    defaultFontId: 'clean',
  ),
  TemplateDef(
    id: 'executive',
    name: 'Executive',
    description: 'Premium appearance, elegant typography, strong header.',
    bestFor: 'Managers, Directors, Senior professionals, Executives',
    engine: LayoutEngine.single,
    defaultColorId: 'dark_gray',
    defaultFontId: 'elegant',
    isPremium: true,
    denseHeader: true,
  ),
  TemplateDef(
    id: 'student',
    name: 'Student / Fresher',
    description: 'Simple, education & project focused.',
    bestFor: 'Students, Fresh graduates, Internships, First job',
    engine: LayoutEngine.single,
    defaultColorId: 'green',
    defaultFontId: 'clean',
  ),
  TemplateDef(
    id: 'tech',
    name: 'Tech Resume',
    description: 'Modern, programming-focused, GitHub/portfolio support.',
    bestFor: 'Developers, Engineers, IT professionals',
    engine: LayoutEngine.sidebar,
    defaultColorId: 'blue',
    defaultFontId: 'modern',
    isPremium: true,
  ),
  TemplateDef(
    id: 'elegant',
    name: 'Elegant',
    description: 'Professional, minimal color, elegant typography.',
    bestFor: 'HR, Education, Consulting, Office jobs',
    engine: LayoutEngine.single,
    defaultColorId: 'purple',
    defaultFontId: 'elegant',
    isPremium: true,
  ),
  TemplateDef(
    id: 'two_column',
    name: 'Two Column',
    description: 'Left sidebar with skills/languages/contact, main content right.',
    bestFor: 'General professionals, Designers, Marketing, Students',
    engine: LayoutEngine.sidebar,
    defaultColorId: 'orange',
    defaultFontId: 'modern',
    isPremium: true,
  ),
];

TemplateDef templateById(String id) =>
    kTemplates.firstWhere((t) => t.id == id, orElse: () => kTemplates.first);

class ColorOption {
  final String id;
  final String name;
  final Color color;
  const ColorOption(this.id, this.name, this.color);
}

const List<ColorOption> kColorOptions = [
  ColorOption('blue', 'Blue', Color(0xFF1E5AA8)),
  ColorOption('black', 'Black', Color(0xFF1A1A1A)),
  ColorOption('dark_gray', 'Dark Gray', Color(0xFF3A3F44)),
  ColorOption('green', 'Green', Color(0xFF1E7145)),
  ColorOption('purple', 'Purple', Color(0xFF6A3FA0)),
  ColorOption('red', 'Red', Color(0xFFB3261E)),
  ColorOption('orange', 'Orange', Color(0xFFC1590A)),
];

Color colorById(String id) => kColorOptions
    .firstWhere((c) => c.id == id, orElse: () => kColorOptions.first)
    .color;

class FontOption {
  final String id;
  final String name;
  final String headingFont; // google_fonts family name
  final String bodyFont;
  const FontOption(this.id, this.name, this.headingFont, this.bodyFont);
}

const List<FontOption> kFontOptions = [
  FontOption('modern', 'Modern', 'Poppins', 'Inter'),
  FontOption('classic', 'Classic', 'Merriweather', 'Lora'),
  FontOption('elegant', 'Elegant', 'Playfair Display', 'Source Sans Pro'),
  FontOption('clean', 'Clean', 'Roboto', 'Roboto'),
];

FontOption fontById(String id) => kFontOptions
    .firstWhere((f) => f.id == id, orElse: () => kFontOptions.first);
