#!/bin/bash
set -e

VERSION="$1"
NAME="toucan"

if [ -z "$VERSION" ]; then
  echo "Usage: $0 <VERSION>"
  exit 1
fi

ARCH="amd64"
BUILD_DIR="build-deb"
PKG_ROOT="$BUILD_DIR/${NAME}_${VERSION}"
INSTALL_PREFIX="/usr/local/bin"
BIN_DIR=".build/release"
BINARY_NAMES=("toucan" "toucan-generate" "toucan-init" "toucan-serve" "toucan-watch")

echo "📦 Building .deb for $NAME version $VERSION"

# Collect matching executables
EXECUTABLES=""
for BINNAME in "${BINARY_NAMES[@]}"; do
  CANDIDATE="$BIN_DIR/$BINNAME"
  if [ -f "$CANDIDATE" ] && [ -x "$CANDIDATE" ]; then
    EXECUTABLES+="$CANDIDATE"$'\n'
  else
    echo "⚠️ Skipping missing or non-executable: $BINNAME"
  fi
done

if [ -z "$EXECUTABLES" ]; then
  echo "❌ No executable binaries found"
  exit 1
fi

# Prepare package directory structure
rm -rf "$PKG_ROOT"
mkdir -p "$PKG_ROOT/DEBIAN"
mkdir -p "$PKG_ROOT$INSTALL_PREFIX"

# Copy binaries
while IFS= read -r BIN; do
  [ -z "$BIN" ] && continue
  BASENAME=$(basename "$BIN")
  cp "$BIN" "$PKG_ROOT$INSTALL_PREFIX/$BASENAME"
  chmod +x "$PKG_ROOT$INSTALL_PREFIX/$BASENAME"
  echo "✅ Added $BASENAME"
done <<< "$EXECUTABLES"

cat > "$PKG_ROOT/DEBIAN/control" <<EOF
Package: $NAME
Version: $VERSION
Architecture: $ARCH
Maintainer: binarybirds <info@binarybirds.com>
Description: $NAME is a static site generator written in Swift.
Section: utils
Priority: optional
EOF

dpkg-deb --build "$PKG_ROOT"
CUSTOM_NAME="toucan-linux-amd64-${VERSION}.deb"
mv "$PKG_ROOT.deb" "$BUILD_DIR/$CUSTOM_NAME"
echo "🎉 DEB created: $BUILD_DIR/$CUSTOM_NAME"