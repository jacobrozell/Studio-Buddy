#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
example="$root/GoogleService-Info.plist.example"
dest="$root/GoogleService-Info.plist"
cp "$example" "$dest"

if [ -z "${GOOGLE_SERVICE_INFO_PLIST_BASE64:-}" ]; then
  echo "error: GOOGLE_SERVICE_INFO_PLIST_BASE64 is not set. Refusing to archive without Firebase." >&2
  exit 1
fi

python3 - "$dest" << 'PY'
import base64, os, pathlib, sys
dest = pathlib.Path(sys.argv[1])
raw = os.environ.get("GOOGLE_SERVICE_INFO_PLIST_BASE64", "")
text = raw.strip()
if text.startswith("<?xml") or text.startswith("<plist"):
    data = text.encode()
else:
    try:
        data = base64.b64decode(text, validate=False)
    except Exception:
        sys.exit("error: GOOGLE_SERVICE_INFO_PLIST_BASE64 is not valid base64")
if b"GOOGLE_APP_ID" not in data or b"REPLACE_WITH" in data:
    sys.exit("error: workflow secret did not decode to a real GoogleService-Info.plist")
dest.write_bytes(data)
print(f"Wrote GoogleService-Info.plist ({len(data)} bytes)")
PY

(cd "$root" && xcodegen generate)
echo "Generated Xcode project from project.yml"
