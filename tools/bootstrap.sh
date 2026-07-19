#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MOBILE_DIR="${ROOT_DIR}/apps/mobile"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter is not installed or not available in PATH."
  exit 1
fi

cd "${MOBILE_DIR}"
flutter create \
  --org com.familyos \
  --project-name family_os \
  --platforms android,ios \
  .
flutter pub get
dart format lib test
flutter analyze
flutter test

echo "Family OS is ready."
