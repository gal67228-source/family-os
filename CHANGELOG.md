# Changelog

## 1.1.4
- Added centralized design tokens.
- Expanded light and dark Material 3 themes.
- Added reusable buttons, cards, text fields, search, scaffold and state views.
- Added design-system widget tests.

## 1.1.3
- Renamed the family domain model to `FamilyWorkspace` to avoid a Riverpod symbol collision.
- Updated every family-model import and type reference.
- Replaced deprecated `RadioListTile` selection APIs with accessible tappable list items.

## 1.1.2
- Made the GitHub workflow permanent and minimal.
- Moved build, format, analysis, tests, commit and release logic to `tools/ci/cloud_build.sh`.
- Future ZIP uploads can update the build script without modifying `.github/workflows`.
- Workflow updates should no longer be required after the one-time installation.

## 1.1.1
- Updated Cloud Builder to format source automatically.
- Analyze and tests now run before any commit is pushed.
- Only verified and formatted code is committed to main.

## 1.1.0
- Added splash, login, registration and password reset screens.
- Added local demo authentication controller with validation and loading states.
- Added create family, join family, invite members and switch family flows.
- Added Admin and regular-member role selection.
- Added sign-out flow and family switching from the app shell.
- Updated tests for the authentication flow.

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
