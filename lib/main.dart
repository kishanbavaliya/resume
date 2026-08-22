import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app.dart';
import 'data/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();

  // Ads are best-effort: if this fails (e.g. no network / not configured)
  // the app continues to work fully offline, just without ad banners.
  try {
    await MobileAds.instance.initialize();
  } catch (_) {}

  runApp(const ResumeMakerApp());
}
