#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT="${ROOT}/StudioBuddy.xcodeproj"
SIM_IPHONE="${SIM_IPHONE:-iPhone 17}"
SIM_IPAD="${SIM_IPAD:-iPad (A16)}"
MCP="${MCP:-npx -y xcodebuildmcp@latest}"

cd "${ROOT}"
xcodegen generate

echo "::group::SwiftLint"
swiftlint --strict
echo "::endgroup::"

echo "::group::Spec drift"
python3 Scripts/ci/check-spec-drift.py
echo "::endgroup::"

run_test() {
  local scheme="$1"
  local sim="$2"
  echo "::group::${scheme} (${sim})"
  ${MCP} simulator test \
    --project-path "${PROJECT}" \
    --scheme "${scheme}" \
    --simulator-name "${sim}" \
    --style minimal
  echo "::endgroup::"
}

run_test StudioBuddyCI "${SIM_IPHONE}"
run_test StudioBuddyUISmoke "${SIM_IPHONE}"
run_test StudioBuddyUILandscape "${SIM_IPHONE}"
run_test StudioBuddyUIAccessibility "${SIM_IPHONE}"
run_test StudioBuddyUIPad "${SIM_IPAD}"

echo "✅ All verification gates passed."
