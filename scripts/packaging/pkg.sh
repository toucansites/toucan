#!/bin/bash
set -e

VERSION="$1"
NAME="toucan"

if [ -z "$VERSION" ]; then
  echo "Usage: $0 <VERSION>"
  exit 1
fi

echo "📦 Creating .pkg and .zip for $NAME version $VERSION"

# Paths
ROOT_DIR=$(pwd)
UNIVERSAL_DIR="$ROOT_DIR/.build/universal"
RELEASE_DIR="$ROOT_DIR/release"
PKGROOT="$ROOT_DIR/pkg-root"
PKGFILE="$RELEASE_DIR/${NAME}-macos-${VERSION}.pkg"
ZIPFILE="$RELEASE_DIR/${NAME}-macos-${VERSION}.zip"
SHAFILE="$RELEASE_DIR/${NAME}-macos-${VERSION}.sha256"
BINARIES=("toucan" "toucan-generate" "toucan-init" "toucan-serve" "toucan-watch")

# Cleanup
rm -rf "$UNIVERSAL_DIR" "$PKGROOT"
mkdir -p "$UNIVERSAL_DIR" "$PKGROOT/usr/local/bin" "$RELEASE_DIR"

# Build universal binaries
for BIN in "${BINARIES[@]}"; do
  ARM64_BIN=".build/arm64-apple-macosx/release/$BIN"
  X86_64_BIN=".build/x86_64-apple-macosx/release/$BIN"
  OUT="$UNIVERSAL_DIR/$BIN"

  if [[ -x "$ARM64_BIN" && -x "$X86_64_BIN" ]]; then
    lipo -create "$ARM64_BIN" "$X86_64_BIN" -output "$OUT"
    echo "✅ Universal binary created: $BIN"

    if [[ -n "$MAC_APP_IDENTITY" ]]; then
      codesign --sign "$MAC_APP_IDENTITY" \
               --options runtime \
               --timestamp \
               --verbose \
               --force "$OUT"
      echo "🔏 Signed: $BIN"
    fi

    cp "$OUT" "$PKGROOT/usr/local/bin/"
  else
    echo "⚠️ Skipping $BIN — missing architecture binary"
  fi
done

# Add LICENSE
mkdir -p "$PKGROOT/usr/local/share/$NAME"
cp LICENSE "$PKGROOT/usr/local/share/$NAME/LICENSE" || echo "⚠️ LICENSE not found"

# Create .pkg
pkgbuild \
  --identifier "com.binarybirds.${NAME}" \
  --version "$VERSION" \
  --install-location / \
  --root "$PKGROOT" \
  "$PKGFILE"

# Sign .pkg
if [[ -n "$MAC_INSTALLER_IDENTITY" ]]; then
  TMPFILE="${PKGFILE}.tmp"
  productsign --sign "$MAC_INSTALLER_IDENTITY" "$PKGFILE" "$TMPFILE"
  mv "$TMPFILE" "$PKGFILE"
  echo "✅ Signed .pkg: $PKGFILE"
else
  echo "⚠️ No MAC_INSTALLER_IDENTITY provided"
fi

# Notarize .pkg
if [[ -n "$APPLE_ID" && -n "$APPLE_TEAM_ID" && -n "$APP_SPECIFIC_PASSWORD" ]]; then
  echo "📤 Notarizing .pkg"
  xcrun notarytool submit "$PKGFILE" \
    --apple-id "$APPLE_ID" \
    --team-id "$APPLE_TEAM_ID" \
    --password "$APP_SPECIFIC_PASSWORD" \
    --wait
  xcrun stapler staple "$PKGFILE"
  echo "✅ Notarization complete"
else
  echo "⚠️ Notarization skipped"
fi

# Zip universal binaries
cd "$UNIVERSAL_DIR"
zip -r "$ZIPFILE" ./*
cd "$ROOT_DIR"

# SHA256 hash
shasum -a 256 "$ZIPFILE" > "$SHAFILE"
echo "✅ SHA256 written: $SHAFILE"