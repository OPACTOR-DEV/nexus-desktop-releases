# nexus-desktop-releases

Public binary mirror for the Nexus desktop app. Source code lives privately in
`OPACTOR-DEV/anymorph-nexus`; only signed build artifacts ship here.

## Install

**One-liner (recommended)** — bypasses macOS Gatekeeper since curl-downloaded
binaries don't get the quarantine flag:

```bash
curl -fsSL https://raw.githubusercontent.com/OPACTOR-DEV/nexus-desktop-releases/main/install.sh | bash
```

Pin a specific version:
```bash
curl -fsSL .../install.sh | NEXUS_VERSION=v0.1.1 bash
```

The script auto-detects Apple Silicon vs Intel, downloads the matching
`.app.tar.gz`, extracts to `/Applications`, and launches the app. No "damaged"
warning, no terminal `xattr` step, no right-click dance.

**Manual** — drag `.dmg` and run `xattr -cr /Applications/Nexus.app` once.
See [latest release](../../releases/latest).

## Updates

The desktop app polls
`https://github.com/OPACTOR-DEV/nexus-desktop-releases/releases/latest/download/latest.json`
on every boot. Bundles are signed with our Tauri ed25519 key — only releases
created by our CI verify against the embedded public key.
