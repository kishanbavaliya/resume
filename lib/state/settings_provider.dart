import 'package:flutter/material.dart';
import '../data/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;

  ThemeMode _themeMode = ThemeMode.system;
  bool _onboardingDone = false;
  bool _isPremium = false;
  String _defaultTemplateId = 'classic_professional';
  String _defaultPaperSize = 'A4';

  ThemeMode get themeMode => _themeMode;
  bool get onboardingDone => _onboardingDone;
  bool get isPremium => _isPremium;
  String get defaultTemplateId => _defaultTemplateId;
  String get defaultPaperSize => _defaultPaperSize;

  void load() {
    final theme = _storage.getSetting<String>('themeMode', 'system');
    _themeMode = switch (theme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    _onboardingDone = _storage.getSetting<bool>('onboardingDone', false) ?? false;
    _isPremium = _storage.getSetting<bool>('isPremium', false) ?? false;
    _defaultTemplateId =
        _storage.getSetting<String>('defaultTemplateId', 'classic_professional') ??
            'classic_professional';
    _defaultPaperSize = _storage.getSetting<String>('defaultPaperSize', 'A4') ?? 'A4';
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _storage.setSetting('themeMode', mode.name);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _onboardingDone = true;
    await _storage.setSetting('onboardingDone', true);
    notifyListeners();
  }

  Future<void> setPremium(bool value) async {
    _isPremium = value;
    await _storage.setSetting('isPremium', value);
    notifyListeners();
  }

  Future<void> setDefaultTemplate(String id) async {
    _defaultTemplateId = id;
    await _storage.setSetting('defaultTemplateId', id);
    notifyListeners();
  }

  Future<void> setDefaultPaperSize(String size) async {
    _defaultPaperSize = size;
    await _storage.setSetting('defaultPaperSize', size);
    notifyListeners();
  }
}
