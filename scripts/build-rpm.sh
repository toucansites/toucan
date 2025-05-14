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
BINARY_NAMES=("toucan" "toucan-generate" "toucan-init" "toucan-serve" "toucan-watch")

echo "📦 Building RPM for $NAME version $VERSION"

# Ensure RPM build directories exist
mkdir -p "$TOPDIR"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

# Create packaging root
PKG_ROOT="$WORKDIR/${NAME}-${VERSION}"
APP_ROOT="$PKG_ROOT/usr/local/bin"
mkdir -p "$APP_ROOT"

# Collect matching executables
EXECUTABLES=""
for BINNAME in "${BINARY_NAMES[@]}"; do
  CANDIDATE="$BIN_DIR/$BINNAME"
  if [ -f "$CANDIDATE" ] && [ -x "$CANDIDATE" ]; then
    EXECUTABLES+="$CANDIDATE"$'\n'
  else
    echo "⚠️  Skipping missing or non-executable: $BINNAME"
  fi
done

if [ -z "$EXECUTABLES" ]; then
  echo "❌ No executables found"
  exit 1
fi

# Copy executables to staging, skipping empty lines
while IFS= read -r BIN; do
  [ -z "$BIN" ] && continue
  BASENAME=$(basename "$BIN")
  cp "$BIN" "$APP_ROOT/"
  chmod +x "$APP_ROOT/$BASENAME"
  echo "✅ Added $BASENAME"
done <<< "$EXECUTABLES"

# Optionally copy docs
cp -f README.md LICENSE "$WORKDIR/${NAME}-${VERSION}/" 2>/dev/null || echo "ℹ️ Skipping docs (optional)"

# Create tarball
tar -czf "$TOPDIR/SOURCES/$TARBALL" -C "$WORKDIR" "${NAME}-${VERSION}"

# Copy .spec file
cp "packaging/${NAME}.spec" "$TOPDIR/SPECS/"

# Build RPM
rpmbuild -ba "$TOPDIR/SPECS/${NAME}.spec" --define "ver $VERSION"

# Move RPM to build-rpm folder with custom name
[ -e build-rpm ] && [ ! -d build-rpm ] && rm build-rpm
FINAL_RPM=$(find "$TOPDIR/RPMS" -type f -name "*.rpm" | head -n1)
CUSTOM_NAME="toucan-linux-x8664-${VERSION}.rpm"
mkdir -p build-rpm
mv "$FINAL_RPM" "build-rpm/$CUSTOM_NAME"

echo "🎉 RPM created: build-rpm/$CUSTOM_NAME"