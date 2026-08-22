import 'dart:async';
import 'package:flutter/material.dart';
import '../data/storage_service.dart';
import '../data/section_definitions.dart';
import '../models/resume.dart';

/// Central state for all resumes + the one currently being edited.
/// Handles auto-save (feature #26: "every major change auto-saves
/// locally, data should not be lost if the app is closed").
class ResumeProvider extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;

  List<Resume> _resumes = [];
  Resume? _current;
  Timer? _autoSaveTimer;

  List<Resume> get resumes => _resumes;
  Resume? get current => _current;

  Future<void> load() async {
    _resumes = _storage.loadAllResumes();
    notifyListeners();
  }

  Resume createResume({String title = 'Untitled Resume'}) {
    final r = Resume(title: title, sections: defaultSections());
    _resumes.insert(0, r);
    _current = r;
    _persist(r);
    notifyListeners();
    return r;
  }

  Resume createFromSample(Resume sample) {
    sample.title = 'My Resume';
    _resumes.insert(0, sample);
    _current = sample;
    _persist(sample);
    notifyListeners();
    return sample;
  }

  void setCurrent(Resume r) {
    _current = r;
    notifyListeners();
  }

  void clearCurrent() {
    _current = null;
  }

  Resume duplicateResume(Resume r) {
    final copy = r.copyWith();
    _resumes.insert(0, copy);
    _persist(copy);
    notifyListeners();
    return copy;
  }

  Future<void> deleteResume(Resume r) async {
    _resumes.removeWhere((x) => x.id == r.id);
    if (_current?.id == r.id) _current = null;
    await _storage.deleteResume(r.id);
    notifyListeners();
  }

  void renameResume(Resume r, String newTitle) {
    r.title = newTitle;
    notifyChangedAndSave();
  }

  /// Call after any edit to a resume. Debounces disk writes slightly but
  /// always keeps in-memory state + UI in sync immediately. Pass the
  /// resume being edited explicitly so this works correctly even if
  /// `current` wasn't set (e.g. editing straight from My Resumes).
  void notifyChangedAndSave([Resume? resume]) {
    notifyListeners();
    final target = resume ?? _current;
    if (target == null) return;
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 400), () {
      _persist(target);
    });
  }

  Future<void> _persist(Resume r) async {
    await _storage.saveResume(r);
  }

  Future<void> saveNow() async {
    if (_current != null) await _persist(_current!);
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }
}
