#!/usr/bin/env bash
# Nexus desktop installer — bypasses macOS Gatekeeper friction by downloading
# via curl (no quarantine flag) and extracting the app into /Applications.
#
# Usage:
#   curl -fsSL https://nexus.opactor.com/install.sh | bash
#   # or:
#   curl -fsSL https://raw.githubusercontent.com/OPACTOR-DEV/nexus-desktop-releases/main/install.sh | bash
#
# Pin a specific version:
#   curl -fsSL .../install.sh | NEXUS_VERSION=v0.1.1 bash

set -euo pipefail

REPO="OPACTOR-DEV/nexus-desktop-releases"
APP="Nexus"
DEST="/Applications"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This installer is macOS-only." >&2
  exit 1
fi

case "$(uname -m)" in
  arm64|aarch64) ARCH="aarch64" ;;
  x86_64)        ARCH="x64" ;;
  *) echo "Unsupported arch: $(uname -m)" >&2; exit 1 ;;
esac

if [[ -z "${NEXUS_VERSION:-}" ]]; then
  echo "→ Resolving latest version…"
  NEXUS_VERSION="$(
    curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
      | grep -o '"tag_name":[[:space:]]*"[^"]*"' \
      | head -1 \
      | cut -d'"' -f4
  )"
fi

if [[ -z "${NEXUS_VERSION}" ]]; then
  echo "Failed to resolve latest version. Set NEXUS_VERSION=vX.Y.Z explicitly." >&2
  exit 1
fi

ASSET="${APP}_${ARCH}.app.tar.gz"
URL="https://github.com/${REPO}/releases/download/${NEXUS_VERSION}/${ASSET}"

echo "→ Installing ${APP} ${NEXUS_VERSION} (${ARCH})"

TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT

echo "→ Downloading ${URL}"
curl -fL --progress-bar -o "${TMP}/${ASSET}" "${URL}"

echo "→ Extracting"
tar -xzf "${TMP}/${ASSET}" -C "${TMP}"

if [[ ! -d "${TMP}/${APP}.app" ]]; then
  echo "Bundle layout unexpected — ${APP}.app not found in archive." >&2
  exit 1
fi

if pgrep -f "${DEST}/${APP}.app/Contents/MacOS" >/dev/null 2>&1; then
  echo "→ Stopping running ${APP}"
  pkill -f "${DEST}/${APP}.app/Contents/MacOS" || true
  sleep 1
fi

echo "→ Installing to ${DEST}/${APP}.app"
rm -rf "${DEST}/${APP}.app"
mv "${TMP}/${APP}.app" "${DEST}/${APP}.app"

# curl-downloaded files don't carry com.apple.quarantine, but clear defensively.
xattr -cr "${DEST}/${APP}.app" 2>/dev/null || true

echo
echo "✅ ${APP} ${NEXUS_VERSION} installed at ${DEST}/${APP}.app"
echo "→ Launching…"
open "${DEST}/${APP}.app"
