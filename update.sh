#!/usr/bin/env bash
# Update script for helium package
# Usage: ./update.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_NIX="$SCRIPT_DIR/package.nix"

echo "Fetching latest version..."
LATEST_VERSION=$(gh api repos/imputnet/helium-linux/releases/latest --jq '.tag_name')

CURRENT_VERSION=$(grep 'version = ' "$PACKAGE_NIX" | head -1 | sed 's/.*"\(.*\)".*/\1/')

echo "Current version: $CURRENT_VERSION"
echo "Latest version:  $LATEST_VERSION"

if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    echo "Already up to date!"
    exit 0
fi

DEB_URL="https://github.com/imputnet/helium-linux/releases/download/${LATEST_VERSION}/helium-bin_${LATEST_VERSION}-1_amd64.deb"

echo "Fetching hash for $LATEST_VERSION..."
NEW_HASH=$(nix-prefetch-url "$DEB_URL" 2>/dev/null)
SRI_HASH=$(nix hash convert --to sri --hash-algo sha256 "$NEW_HASH")

echo "New SRI hash: $SRI_HASH"

sed -i "s/version = \"[^\"]*\"/version = \"$LATEST_VERSION\"/" "$PACKAGE_NIX"
sed -i "s|hash = \"sha256-[^\"]*\"|hash = \"$SRI_HASH\"|" "$PACKAGE_NIX"

echo "Updated package.nix to version $LATEST_VERSION"
