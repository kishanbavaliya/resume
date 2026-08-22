import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/resume.dart';

/// Wraps Hive so the rest of the app never touches raw boxes.
/// Resumes are stored as JSON strings — this avoids needing generated
/// Hive TypeAdapters / build_runner, which keeps setup to a single
/// `flutter pub get`.
class StorageService {
  static const _resumesBox = 'resumes_box';
  static const _settingsBox = 'settings_box';

  late Box<String> _resumes;
  late Box _settings;

  static final StorageService instance = StorageService._();
  StorageService._();

  Future<void> init() async {
    await Hive.initFlutter();
    _resumes = await Hive.openBox<String>(_resumesBox);
    _settings = await Hive.openBox(_settingsBox);
  }

  // ----- Resumes -----

  List<Resume> loadAllResumes() {
    return _resumes.values
        .map((s) {
          try {
            return Resume.fromJson(jsonDecode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<Resume>()
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> saveResume(Resume resume) async {
    resume.updatedAt = DateTime.now();
    await _resumes.put(resume.id, jsonEncode(resume.toJson()));
  }

  Future<void> deleteResume(String id) async {
    await _resumes.delete(id);
  }

  // ----- Settings (generic key/value) -----

  T? getSetting<T>(String key, [T? fallback]) {
    final v = _settings.get(key);
    return (v as T?) ?? fallback;
  }

  Future<void> setSetting(String key, dynamic value) async {
    await _settings.put(key, value);
  }
}
