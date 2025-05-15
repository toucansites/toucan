#!/bin/bash
set -e

VERSION="$1"
DMG_NAME="toucan-macos-${VERSION}.dmg"
VOL_NAME="Toucan Installer"
PKG_NAME="toucan-macos-${VERSION}.pkg"

RELEASE_DIR="$(pwd)/release"
PKG_PATH="${RELEASE_DIR}/${PKG_NAME}"
DMG_PATH="${RELEASE_DIR}/${DMG_NAME}"
DMG_ROOT="$(pwd)/dmg-root"
LICENSE_SOURCE="./LICENSE"

if [ -z "$VERSION" ]; then
  echo "Usage: $0 <VERSION>"
  exit 1
fi

if [ ! -f "$PKG_PATH" ]; then
  echo "❌ .pkg file not found at $PKG_PATH"
  exit 1
fi

echo "📦 Creating .dmg from $PKG_NAME"

rm -rf "$DMG_ROOT"
mkdir -p "$DMG_ROOT"

# Copy and rename .pkg
cp "$PKG_PATH" "$DMG_ROOT/Toucan.pkg"

# Copy LICENSE file
if [ -f "$LICENSE_SOURCE" ]; then
  cp "$LICENSE_SOURCE" "$DMG_ROOT/LICENSE"
else
  echo "⚠️ LICENSE file not found at $LICENSE_SOURCE"
fi

# Create README
cat > "$DMG_ROOT/README.txt" <<EOF
Toucan Installer

To install:
1. Double-click the 'Install Toucan' script
2. Enter your admin password if prompted

Or, install manually by double-clicking the 'Toucan.pkg' file.
EOF

# Create install script
cat > "$DMG_ROOT/Install Toucan.command" <<EOF
#!/bin/bash
set -e
echo "Launching Toucan Installer..."
open "/Volumes/${VOL_NAME}/Toucan.pkg"
EOF

chmod +x "$DMG_ROOT/Install Toucan.command"

# Optional: Sign the .command script
if [[ -n "$MAC_APP_IDENTITY" ]]; then
  echo "🔏 Signing 'Install Toucan.command' with identity: $MAC_APP_IDENTITY"
  codesign --sign "$MAC_APP_IDENTITY" --force --timestamp --verbose "$DMG_ROOT/Install Toucan.command"
  echo "✅ Signed Install Toucan.command"
else
  echo "⚠️ No codesign identity provided. Script remains unsigned."
fi

# Create the DMG
hdiutil create \
  -volname "$VOL_NAME" \
  -srcfolder "$DMG_ROOT" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

echo "✅ .dmg created: $DMG_PATH"

# Optional: Sign the .dmg file
if [[ -n "$MAC_APP_IDENTITY" ]]; then
  echo "🔏 Signing DMG with identity: MAC_APP_IDENTITY"
  codesign --sign "$MAC_APP_IDENTITY" --force --timestamp --verbose "$DMG_PATH"
  echo "✅ DMG signed: $DMG_PATH"
else
  echo "⚠️ No codesign identity provided. DMG file remains unsigned."
fi

# Optional: Notarize the .dmg file with Apple
if [[ -n "$APPLE_ID" && -n "$APPLE_TEAM_ID" && -n "$APP_SPECIFIC_PASSWORD" ]]; then
  echo "📤 Submitting $DMG_PATH for notarization..."
  xcrun notarytool submit "$DMG_PATH" \
    --apple-id "$APPLE_ID" \
    --team-id "$APPLE_TEAM_ID" \
    --password "$APP_SPECIFIC_PASSWORD" \
    --wait

  echo "📎 Stapling notarization ticket to $DMG_PATH"
  xcrun stapler staple "$DMG_PATH"
  echo "✅ Notarization and stapling complete"
else
  echo "⚠️ Notarization skipped — missing APPLE_ID, TEAM_ID, or APP_PASSWORD"
fi