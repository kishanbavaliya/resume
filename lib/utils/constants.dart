import 'dart:io';

/// AdMob configuration (feature #41/#42: Banner on Home/Templates,
/// Native in template list, Interstitial between non-critical screens,
/// optional Rewarded to unlock a template).
///
/// These are Google's official *test* ad unit IDs — safe to ship in
/// debug builds and won't earn revenue or risk policy violations.
/// Replace with your real AdMob IDs before release (see README).
class AdConfig {
  static bool adsEnabled = true; // flipped off automatically for Premium

  static String get bannerAdUnitId => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/2934735716'
      : 'ca-app-pub-3940256099942544/6300978111';

  static String get interstitialAdUnitId => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/4411468910'
      : 'ca-app-pub-3940256099942544/1033173712';

  static String get rewardedAdUnitId => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/1712485313'
      : 'ca-app-pub-3940256099942544/5224354917';

  static String get nativeAdUnitId => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/3986624511'
      : 'ca-app-pub-3940256099942544/2247696110';

  // Your real AdMob App ID also needs to be set in
  // android/app/src/main/AndroidManifest.xml and ios/Runner/Info.plist.
  static const String androidAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String iosAppId = 'ca-app-pub-3940256099942544~1458002511';
}

class AppConstants {
  static const String appName = 'Resume Maker';
  static const String privacyPolicyText = '''
Resume Maker works entirely offline. All resume data you enter — personal 
information, work experience, education, and everything else — is stored 
only on your device using local storage. Nothing is uploaded to any 
server or cloud automatically.

No account or login is required to use this app.

Profile photos and generated PDF files are saved to your device's local 
storage and are only shared when you explicitly choose to share or export 
them via your device's share sheet.

If ads are shown (free version), ad partners (Google AdMob) may collect 
limited data as described in their own privacy policies.

You can delete any resume, or all app data, at any time from within the 
app or your device settings.
''';

  static const String termsText = '''
By using Resume Maker you agree to use the app for lawful purposes only. 
The app is provided "as is" without warranty of any kind. We are not 
responsible for the accuracy of content you create, nor for how 
third parties (e.g. employers) evaluate documents generated with this 
app. ATS-compatibility features are provided as a best-effort guide only 
and results can vary by employer and by the software they use.
''';
}
