#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-}"
if [[ -z "${VERSION}" ]]; then
  echo "Usage: ./tools/release.sh 0.1.0"
  exit 1
fi

git tag "v${VERSION}"
git push origin "v${VERSION}"

echo "Release v${VERSION} was triggered in GitHub Actions."
