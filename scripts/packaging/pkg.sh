#!/bin/bash
set -e

VERSION="$1"
NAME="toucan"

if [ -z "$VERSION" ]; then
  echo "Usage: $0 <VERSION>"
  exit 1
fi

echo "📦 Creating .pkg for version $VERSION"

# Paths
ROOT_DIR=$(pwd)
PKGROOT="$ROOT_DIR/pkg-root"
RELEASE_DIR="$ROOT_DIR/release"
PKGFILE="$RELEASE_DIR/toucan-macos-${VERSION}.pkg"
BIN_DIR=".build/release"
BINARY_NAMES=("toucan" "toucan-generate" "toucan-init" "toucan-serve" "toucan-watch")

# Collect matching executables
EXECUTABLES=""
for NAME in "${BINARY_NAMES[@]}"; do
  CANDIDATE="$BIN_DIR/$NAME"
  if [ -f "$CANDIDATE" ] && [ -x "$CANDIDATE" ]; then
    EXECUTABLES+="$CANDIDATE"$'\n'
  fi
done

if [ -z "$EXECUTABLES" ]; then
  echo "❌ No executable binaries found"
  exit 1
fi

# Prepare packaging structure
rm -rf "$PKGROOT"
mkdir -p "$PKGROOT/usr/local/bin"
mkdir -p "$RELEASE_DIR"

# Sign each binary before packaging
for BIN in $EXECUTABLES; do
  BASENAME=$(basename "$BIN")
  DEST="$PKGROOT/usr/local/bin/$BASENAME"
  cp "$BIN" "$DEST"
  chmod +x "$DEST"

  if [[ -n "$MAC_APP_IDENTITY" ]]; then
    echo "🔏 Signing $DEST with identity: $MAC_APP_IDENTITY"
    codesign --sign "$MAC_APP_IDENTITY" \
             --options runtime \
             --timestamp \
             --verbose \
             --force "$DEST"
  else
    echo "⚠️ No MAC_APP_IDENTITY provided. $BASENAME will not be signed."
  fi

  echo "✅ Prepared $BASENAME"
done

# Add LICENSE file
echo "📄 Adding LICENSE file"
mkdir -p "$PKGROOT/usr/local/share/$NAME"
cp LICENSE "$PKGROOT/usr/local/share/$NAME/LICENSE"

# Create unsigned .pkg
pkgbuild \
  --identifier "com.yourcompany.${NAME}" \
  --version "$VERSION" \
  --install-location / \
  --root "$PKGROOT" \
  "$PKGFILE"


# Sign .pkg
if [[ -n "$MAC_INSTALLER_IDENTITY" ]]; then
  echo "🔏 Signing .pkg with identity: $MAC_INSTALLER_IDENTITY"
  TMPFILE="${PKGFILE}.tmp"
  productsign --sign "$MAC_INSTALLER_IDENTITY" "$PKGFILE" "$TMPFILE"
  mv "$TMPFILE" "$PKGFILE"
  echo "✅ Signed .pkg: $PKGFILE"
else
  echo "⚠️ No MAC_INSTALLER_IDENTITY provided. .pkg will remain unsigned."
fi

# Notarize .pkg
if [[ -n "$APPLE_ID" && -n "$APPLE_TEAM_ID" && -n "$APP_SPECIFIC_PASSWORD" ]]; then
  echo "📤 Submitting $PKGFILE for notarization..."
  xcrun notarytool submit "$PKGFILE" \
    --apple-id "$APPLE_ID" \
    --team-id "$APPLE_TEAM_ID" \
    --password "$APP_SPECIFIC_PASSWORD" \
    --wait

  echo "📎 Stapling notarization ticket to $PKGFILE"
  xcrun stapler staple "$PKGFILE"
  echo "✅ Notarization and stapling complete"
else
  echo "⚠️ Notarization skipped — missing APPLE_ID, TEAM_ID, or APP_SPECIFIC_PASSWORD"
fi