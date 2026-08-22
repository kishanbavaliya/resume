# Resume Maker — Flutter App

A complete, offline-first Resume/CV builder built in Flutter, based on your
product specification: 10 editable templates, a live preview, 13 resume
sections, multi-resume management, PDF export, dark mode, AdMob scaffolding,
and a Premium unlock flow — all working with **no backend**.

---

## ⚠️ Important: read this first

This project was hand-written in a sandboxed environment **without the
Flutter SDK or internet access**, so I was not able to run
`flutter create`, `flutter pub get`, `flutter analyze`, or `flutter run` to
compile-check it myself. I wrote it carefully, in a consistent architecture,
but you should treat the first build on your machine as the real
verification step — see **Troubleshooting** below for the most likely
first-run issues and fixes.

The **`android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/`** platform
folders are **not included** in this zip. That's intentional, not an
oversight — those folders are large, toolchain-generated, and version
specific. Regenerating them locally with *your* installed Flutter version
guarantees they're compatible with your setup. Step 2 below shows exactly
how.

---

## What's included

```
resume_maker/
├── pubspec.yaml
├── lib/
│   ├── main.dart                     # entry point
│   ├── app.dart                      # MaterialApp, theming, providers
│   ├── models/
│   │   ├── resume.dart               # Resume, PersonalInfo, Section, Entry
│   │   └── template.dart             # 10 templates, colors, fonts
│   ├── data/
│   │   ├── storage_service.dart      # Hive local storage (JSON-based)
│   │   └── section_definitions.dart  # field configs, sample data, tips
│   ├── state/
│   │   ├── resume_provider.dart      # CRUD + auto-save
│   │   └── settings_provider.dart    # theme, premium, defaults
│   ├── screens/                      # 16 screens (see checklist below)
│   ├── widgets/                      # preview renderer, template cards, etc.
│   └── pdf/
│       └── pdf_generator.dart        # mirrors the on-screen template in PDF
└── assets/
```

## Feature checklist (spec → implementation)

| Spec section | Status |
|---|---|
| 1-3. App overview, main flow, Home screen | ✅ Home tab with Create/Sample/Continue/View Saved + completion score |
| 4. Personal Information | ✅ `personal_info_screen.dart` incl. photo, show/hide toggles |
| 5. Professional Summary | ✅ `summary_screen.dart`, char counter, profession examples |
| 6-18. Experience, Education, Skills, Projects, Certifications, Languages, Achievements, Awards, Volunteer, Publications, Interests, References, Custom Section | ✅ One generic engine (`section_editor_screen.dart` + `section_definitions.dart`) drives all 13 section types — add/edit/duplicate/delete/reorder entries |
| 19. Section management (add/remove/hide/reorder/rename) | ✅ In `resume_editor_screen.dart` — drag reorder, Manage Sections sheet |
| 20. 10 Editable Templates | ✅ `models/template.dart` — 2 layout engines × styling presets = 10 named templates |
| 21. Template customization (color/font/layout/display) | ✅ `customize_template_screen.dart` |
| 22-23. Live Preview / Resume Editor | ✅ `live_preview_screen.dart`, section cards in editor |
| 24-25. Multiple resumes, duplicate | ✅ `my_resumes_screen.dart` |
| 26. Auto-save | ✅ Debounced auto-save in `resume_provider.dart` |
| 27. Offline functionality | ✅ Everything (incl. PDF export) works with no network |
| 28-29. PDF generation & actions | ✅ `pdf_export_screen.dart` — A4/Letter, filename, Save/Share/Print/Delete |
| 30. Image handling | ✅ Gallery picker + resize via `image_picker`; shape handled per-template |
| 31. Completion score | ✅ `completion_score_widget.dart` |
| 32. Resume Tips | ✅ `resume_tips_screen.dart`, fully offline content |
| 33. Sample content | ✅ "Use Sample" on Home |
| 34. Job-specific suggestions | ✅ Data in `section_definitions.dart` (`jobSuggestedSections`) |
| 35. ATS-Friendly Mode | ✅ Toggle in Customize Template |
| 36-37. Privacy & security | ✅ `privacy_screen.dart`, local-only storage |
| 38-39. Settings & Dark Mode | ✅ `settings_screen.dart` |
| 40. Languages (i18n) | ⚠️ Architecture is ready (all UI strings are simple literals you can extract), but only English text is written — see "Next steps" |
| 41-43. Monetization, AdMob, Premium templates | ✅ `ad_banner_widget.dart` (test ad unit IDs), `premium_screen.dart` (flips a local flag — needs real billing SDK, see below) |
| 44. Onboarding | ✅ `onboarding_screen.dart` — 4 screens |
| 45-46. Navigation & screen list | ✅ Bottom nav + all screens |
| 47-48. Data architecture / tech stack | ✅ Adapted to Flutter: Provider (~MVVM) + Hive (~Room) + DataStore-equivalent settings box |
| 49-51. MVP / V2 / V3 scope | This build ships the full V2 feature set. V3 items (Cover Letter Builder, Job Tracker, Interview Prep, AI writing) are **not** built — they need a backend/AI service per your own spec (§51) |
| 52. Product rules (no login, offline-first, auto-save...) | ✅ Followed throughout |

---

## Step 1 — Install prerequisites

- Flutter SDK 3.22+ (`flutter --version`) — https://docs.flutter.dev/get-started/install
- Android Studio (for the Android SDK + an emulator) and/or Xcode (macOS, for iOS)
- Run `flutter doctor` and resolve anything it flags before continuing.

## Step 2 — Unzip and add the platform folders

```bash
unzip resume_maker.zip
cd resume_maker

# Generate a throwaway scaffold with YOUR Flutter version, just to get
# fresh android/ios/... folders. Replace the org with your own domain
# (reverse-DNS) — this becomes your Android applicationId / iOS bundle id.
cd ..
flutter create --platforms=android,ios --org com.yourcompany resume_maker_scaffold

# Copy only the generated platform folders into your real project
cp -r resume_maker_scaffold/android resume_maker/
cp -r resume_maker_scaffold/ios resume_maker/
rm -rf resume_maker_scaffold

cd resume_maker
```

(Add `,web,macos,windows,linux` to `--platforms` if you want those targets
too — this app has no platform-specific code, so it should run on all of
them.)

## Step 3 — Install packages

```bash
flutter pub get
```

## Step 4 — Android manifest additions (required for ads)

Open `android/app/src/main/AndroidManifest.xml` and add this **inside**
the `<application>` tag (Google's public test App ID — swap for your real
one before release, see Step 6):

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>
```

## Step 5 — iOS Info.plist additions (required for ads + photo picker)

Open `ios/Runner/Info.plist` and add:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Resume Maker needs photo access to add a profile picture to your resume.</string>
```

## Step 6 — Run it

```bash
flutter run
```

Pick a connected device/emulator when prompted. First launch will show the
splash screen → onboarding → home.

---

## Going to production

1. **Real AdMob IDs** — replace every ID in `lib/utils/constants.dart`
   (`AdConfig`) and the manifest/plist entries above with your own AdMob
   app + ad unit IDs from https://apps.admob.com. Until you do, the app
   uses Google's official test IDs — safe for development, but Google
   will not pay out on them and you must not ship a store build with them.
2. **In-app purchases** — `premium_screen.dart` currently just flips a
   local flag so you can see the unlocked state. Wire it to the
   [`in_app_purchase`](https://pub.dev/packages/in_app_purchase) package
   and your Play Console / App Store Connect product IDs for real billing.
3. **App icon & name** — replace `android/app/src/main/res/mipmap-*` and
   `ios/Runner/Assets.xcassets/AppIcon.appiconset`, and update
   `flutter_launcher_icons` if you add that package. Change the app name
   in `android/app/src/main/AndroidManifest.xml` (`android:label`) and
   `ios/Runner/Info.plist` (`CFBundleName`).
4. **Localization (spec §40)** — the architecture doesn't hard-block
   Phase 2 languages; extract the literal strings in `lib/screens/*.dart`
   into `.arb` files with `flutter_localizations` + `intl` when you're
   ready to add Spanish/French/etc.
5. **PDF fonts** — PDF export intentionally uses the built-in Helvetica/
   Times core fonts so it always works fully offline (see the comment in
   `lib/pdf/pdf_generator.dart`). The in-app live preview uses nicer
   Google Fonts, downloaded on first use. If you want the *exported PDF*
   to match those fonts exactly, bundle the `.ttf` files as assets and
   swap `pw.Font.helvetica()` etc. for `pw.Font.ttf(...)`.

## Troubleshooting first build

- **Version-mismatch errors on a plugin** (e.g. `google_mobile_ads`,
  `printing`, `pdf`, `image_picker`): run `flutter pub outdated` and bump
  the version in `pubspec.yaml` to whatever your Flutter SDK's Dart
  version supports, then `flutter pub get` again.
- **`minSdkVersion` errors on Android**: open
  `android/app/build.gradle(.kts)` and set `minSdk = 21` (or higher) —
  `google_mobile_ads` and `image_picker` require at least API 21.
- **Gradle/AGP version errors**: these come from the scaffold you
  generated in Step 2 with your own Flutter version, so they should
  already match — if not, open the project in Android Studio once and
  let it offer to upgrade Gradle.
- **A screen/widget name collides with something in a newer Flutter
  version** (Flutter occasionally renames Material 3 widgets): the
  compiler error will name the exact widget/property; it's usually a
  one-line rename (e.g. `CardTheme` → `CardThemeData`, already used here
  for Flutter 3.22+).

---

## Design notes (why it's built this way)

- **One generic engine for all 13 repeatable sections.** Rather than 13
  bespoke screens, `SectionConfig` (in `section_definitions.dart`)
  describes each section's fields once; `section_editor_screen.dart`
  renders the list + entry form for whichever section type you open.
  Adding a 14th section type later is a ~15-line config addition, not a
  new screen.
- **2 layout engines power 10 templates.** `single` (Classic, Minimal,
  ATS, Executive, Student, Elegant) and `sidebar` (Modern Blue, Creative,
  Tech, Two Column) differ by color/font/photo-shape presets, not
  duplicated layout code — easy to add an 11th template.
- **`ResumePreview` (screen) and `PdfGenerator` (export) are deliberately
  parallel implementations**, not a shared renderer, because Flutter
  widgets and `pdf` package widgets are different APIs. If you change one
  template visually, mirror the change in the other file.
- **No `hive_generator`/`build_runner` step.** Resumes are stored as JSON
  strings in a Hive box instead of generated TypeAdapters, so
  `flutter pub get` is the only codegen step you need.
