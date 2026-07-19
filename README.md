# Family OS

Family OS is a Flutter-first family organization platform.

## Included in this starter

- Flutter application source
- Material 3 light and dark themes
- Riverpod state management
- GoRouter navigation
- Hebrew RTL starter UI
- Basic screens: Today, Tasks, Shopping, More
- Unit/widget test
- CI for formatting, analysis, tests, APK and AAB builds
- Automatic GitHub Release when pushing a tag such as `v0.1.0`
- Product and architecture documentation

## Prerequisites

- Flutter stable
- Android Studio or Android SDK
- Git

## First local setup

The generated ZIP intentionally keeps platform boilerplate out of source control.
Create Android and iOS folders once:

```bash
cd apps/mobile
flutter create --org com.familyos --project-name family_os --platforms android,ios .
flutter pub get
flutter run
```

## Quality checks

```bash
cd apps/mobile
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

## Android build

```bash
cd apps/mobile
flutter build apk --release
flutter build appbundle --release
```

Outputs:

- `apps/mobile/build/app/outputs/flutter-apk/app-release.apk`
- `apps/mobile/build/app/outputs/bundle/release/app-release.aab`

## Automatic Android version

Pushes and pull requests run verification and Android builds.

To create a downloadable GitHub Release:

```bash
git tag v0.1.0
git push origin v0.1.0
```

GitHub Actions creates:

- `family-os-v0.1.0.apk`
- `family-os-v0.1.0.aab`

The AAB produced by this starter uses the generated development signing setup.
Before publishing to Google Play, configure a private upload keystore using
GitHub Actions secrets. Never commit a keystore or passwords.

## Repository structure

```text
family-os/
├── apps/mobile/
├── packages/
├── backend/supabase/
├── docs/
├── tools/
└── .github/workflows/
```


## Cloud Builder

This repository also includes an optional phone-first build portal:

```text
tools/cloud-builder/cloudflare/
docs/11_Cloud_Builder_Setup_HE.md
.github/workflows/cloud-builder.yml
```

The portal lets you upload a project ZIP from a phone, trigger GitHub Actions,
and download the generated APK from GitHub Releases.

## First upload to an empty repository

Extract this ZIP and upload all files and folders to the root of:

```text
gal67228-source/family-os
```

Important: upload the extracted contents, not the ZIP file itself.
