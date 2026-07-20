#!/usr/bin/env bash
set -euo pipefail

readonly SOURCE_DIR="/tmp/family-os-source"
readonly REPOSITORY_DIR="${GITHUB_WORKSPACE}"
readonly MOBILE_DIR="${REPOSITORY_DIR}/apps/mobile"
readonly RELEASE_DIR="${REPOSITORY_DIR}/release"

if [[ -z "${BUILD_VERSION:-}" ]]; then
  echo "BUILD_VERSION is required."
  exit 1
fi

if [[ ! "${BUILD_VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "BUILD_VERSION must use semantic versioning, for example 1.1.2."
  exit 1
fi

echo "Synchronizing uploaded source without modifying GitHub workflows..."
rsync -a --delete \
  --exclude='.git/' \
  --exclude='.github/workflows/' \
  "${SOURCE_DIR}/" "${REPOSITORY_DIR}/"

git -C "${REPOSITORY_DIR}" restore \
  --source=HEAD \
  --staged \
  --worktree \
  .github/workflows

if ! git -C "${REPOSITORY_DIR}" diff --quiet -- .github/workflows; then
  echo "Workflow files changed unexpectedly."
  git -C "${REPOSITORY_DIR}" diff -- .github/workflows
  exit 1
fi

echo "Installing Java and Flutter is handled by the script."
if ! command -v java >/dev/null 2>&1; then
  echo "Java is unavailable."
  exit 1
fi

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter is unavailable."
  exit 1
fi

cd "${MOBILE_DIR}"

flutter create \
  --org com.familyos \
  --project-name family_os \
  --platforms android,ios \
  .

if [[ -f test/widget_test.dart ]] && grep -q "MyApp" test/widget_test.dart; then
  rm test/widget_test.dart
fi

flutter pub get
dart format lib test
flutter analyze
flutter test

cd "${REPOSITORY_DIR}"

git config user.name "Family OS Cloud Builder"
git config user.email "actions@users.noreply.github.com"
git add --all -- ':!.github/workflows/**'

if ! git diff --cached --quiet -- .github/workflows; then
  echo "Refusing to commit workflow changes."
  git diff --cached -- .github/workflows
  exit 1
fi

if ! git diff --cached --quiet; then
  git commit -m "build: verified source for v${BUILD_VERSION}"
  git push origin HEAD:main
fi

cd "${MOBILE_DIR}"

flutter build apk --release \
  --build-name "${BUILD_VERSION}" \
  --build-number "${BUILD_NUMBER}"

flutter build appbundle --release \
  --build-name "${BUILD_VERSION}" \
  --build-number "${BUILD_NUMBER}"

rm -rf "${RELEASE_DIR}"
mkdir -p "${RELEASE_DIR}"

cp build/app/outputs/flutter-apk/app-release.apk \
  "${RELEASE_DIR}/family-os-v${BUILD_VERSION}-build-${BUILD_NUMBER}.apk"

cp build/app/outputs/bundle/release/app-release.aab \
  "${RELEASE_DIR}/family-os-v${BUILD_VERSION}-build-${BUILD_NUMBER}.aab"

gh release create "build-v${BUILD_VERSION}-${BUILD_NUMBER}" \
  "${RELEASE_DIR}"/* \
  --target main \
  --title "Family OS v${BUILD_VERSION} · Build ${BUILD_NUMBER}" \
  --notes "Automatic verified build from the Family OS Cloud Builder."
