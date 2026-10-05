#!/usr/bin/env bash
# Reprint docs/device-set-and-installation-guide.pdf from the HTML source.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
html="${root}/docs/device-set-and-installation-guide.html"
pdf="${root}/docs/device-set-and-installation-guide.pdf"

if [[ -n "${CHROME:-}" ]]; then
  chrome="$CHROME"
elif [[ -x /opt/google/chrome/chrome ]]; then
  chrome=/opt/google/chrome/chrome
else
  chrome=google-chrome
fi

if [[ ! -f "$html" ]]; then
  echo "missing HTML source: $html" >&2
  exit 1
fi

profile="$(mktemp -d)"
trap 'rm -rf "$profile"' EXIT

"$chrome" \
  --headless=new \
  --disable-gpu \
  --no-sandbox \
  --disable-dev-shm-usage \
  --user-data-dir="$profile" \
  --no-first-run \
  --no-default-browser-check \
  --no-pdf-header-footer \
  --print-to-pdf="$pdf" \
  "file://${html}"

if [[ ! -s "$pdf" ]]; then
  echo "Chrome did not write the PDF" >&2
  exit 1
fi

echo "Wrote ${pdf}"
