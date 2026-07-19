# Changelog

## 1.0.7
- Added Flutter Material, Widgets and Cupertino localization delegates.
- Fixed Hebrew Material localizations for AppBar and NavigationBar.
- Strengthened the widget test to fail on framework exceptions.

## 1.0.6
- Wrapped the app widget test with Riverpod `ProviderScope`.
- Kept the Today screen assertions active.

## 1.0.5
- Rebuilt Cloud Builder workflow from scratch.
- Preserved ZIP download and validation steps.
- Excluded `.github/workflows` from source synchronization and staging.
- Added explicit workflow integrity checks.
- Kept generated-test cleanup before analysis.

## 1.0.3
- Preserved all existing `.github/workflows` files during ZIP replacement.
- Prevented GitHub Actions from attempting to modify workflow files during automated pushes.

## 1.0.2
- Removed Flutter's generated `widget_test.dart` that referenced `MyApp`.
- Updated CI, Android Release and Cloud Builder workflows to remove the default test after `flutter create`.

## 1.0.1
- Fixed Dart formatting in `apps/mobile/lib/app/router.dart`.

## 0.1.0

- Added Flutter starter application.
- Added Hebrew RTL navigation shell.
- Added Today, Tasks, Shopping and More screens.
- Added Material 3 design system foundations.
- Added GitHub Actions verification and Android release workflows.
- Added initial product and technical documentation.
