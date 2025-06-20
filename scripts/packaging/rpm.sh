#!/bin/bash
set -e

VERSION="$1"
NAME="toucan"

if [ -z "$VERSION" ]; then
  echo "Usage: $0 <VERSION>"
  exit 1
fi

TARBALL="${NAME}-${VERSION}.tar.gz"
TOPDIR="$HOME/rpmbuild"
BIN_DIR=".build/release"
BUILD_DIR="build-rpm"
BINARY_NAMES=("toucan" "toucan-generate" "toucan-init" "toucan-serve" "toucan-watch")

echo "📦 Building RPM for $NAME version $VERSION"

# Prepare RPM directories
mkdir -p "$TOPDIR"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
mkdir -p "$BUILD_DIR"
WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

# Stage binaries
SRC_DIR="$WORKDIR/${NAME}-${VERSION}/usr/local/bin"
mkdir -p "$SRC_DIR"
EXECUTABLES=()

for BIN in "${BINARY_NAMES[@]}"; do
  SRC="$BIN_DIR/$BIN"
  if [ -x "$SRC" ]; then
    cp "$SRC" "$SRC_DIR/"
    chmod +x "$SRC_DIR/$BIN"
    EXECUTABLES+=("$BIN")
    echo "✅ Staged: $BIN"
  else
    echo "⚠️ Skipped: $BIN"
  fi
done

if [ ${#EXECUTABLES[@]} -eq 0 ]; then
  echo "❌ No valid executables found"
  exit 1
fi

# Optionally include license file and readme file
cp -f LICENSE README.md "$WORKDIR/${NAME}-${VERSION}/" 2>/dev/null || echo "ℹ️ File(s) not found"

# Create source tarball for rpmbuild
tar -czf "$TOPDIR/SOURCES/$TARBALL" -C "$WORKDIR" "${NAME}-${VERSION}"

# Copy .spec file
cp "./scripts/packaging/${NAME}.spec" "$TOPDIR/SPECS/"

# Build the RPM
rpmbuild -ba "$TOPDIR/SPECS/${NAME}.spec" --define "ver $VERSION"

# Copy and rename RPM
FINAL_RPM=$(find "$TOPDIR/RPMS" -type f -name "*.rpm" | head -n1)
RPM_OUTPUT="$BUILD_DIR/${NAME}-linux-x86_64-${VERSION}.rpm"
cp "$FINAL_RPM" "$RPM_OUTPUT"
echo "🎉 RPM created: $RPM_OUTPUT"

# Create ZIP of raw binaries
ZIP_NAME="${NAME}-linux-${VERSION}.zip"
SHA_NAME="${NAME}-linux-${VERSION}.sha256"
ZIP_DIR="$BUILD_DIR/bin"

rm -rf "$ZIP_DIR"
mkdir -p "$ZIP_DIR"

for BIN in "${EXECUTABLES[@]}"; do
  cp "$BIN_DIR/$BIN" "$ZIP_DIR/"
done

cd "$ZIP_DIR"
zip "../$ZIP_NAME" ./*
cd - >/dev/null

# Create SHA256
cd "$BUILD_DIR"
shasum -a 256 "$ZIP_NAME" > "$SHA_NAME"
cd - >/dev/null

echo "✅ ZIP created: $BUILD_DIR/$ZIP_NAME"
echo "✅ SHA256 created: $BUILD_DIR/$SHA_NAME"
