# nexus-desktop-releases

Public binary mirror for the Nexus desktop app. Source code lives privately in
`OPACTOR-DEV/anymorph-nexus`; only signed build artifacts ship here.

## Install (one-time)

1. Grab the matching `.dmg` from the [latest release](../../releases/latest):
   - Apple Silicon → `Nexus_<ver>_aarch64.dmg`
   - Intel → `Nexus_<ver>_x64.dmg`
2. Drag **Nexus.app** to `/Applications`.
3. Once in Terminal:
   ```bash
   xattr -cr /Applications/Nexus.app
   ```
4. Run the app — auto-updates from now on.

## Updates

The desktop app polls
`https://github.com/OPACTOR-DEV/nexus-desktop-releases/releases/latest/download/latest.json`
on every boot. Bundles are signed with our Tauri ed25519 key — only releases
created by our CI verify against the embedded public key.
