#!/usr/bin/env bash
# Update script for helium packages
# Usage: ./update.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# When run via `nix run .#update` the script lives in the read-only store;
# operate on the current directory instead.
if [[ "$SCRIPT_DIR" == /nix/store/* ]]; then
    SCRIPT_DIR="$PWD"
fi

echo "Fetching latest release..."
RELEASE_JSON=$(gh api repos/imputnet/helium-linux/releases/latest)
LATEST_VERSION=$(jq -r '.tag_name' <<<"$RELEASE_JSON")

update_package() {
    local package_nix="$1" deb_arch="$2"

    local current_version
    current_version=$(grep 'version = ' "$package_nix" | head -1 | sed 's/.*"\(.*\)".*/\1/')

    echo "[$deb_arch] current: $current_version, latest: $LATEST_VERSION"

    if [ "$current_version" = "$LATEST_VERSION" ]; then
        echo "[$deb_arch] already up to date!"
        return
    fi

    local asset="helium-bin_${LATEST_VERSION}-1_${deb_arch}.deb"
    local digest
    digest=$(jq -r --arg name "$asset" '.assets[] | select(.name == $name) | .digest' <<<"$RELEASE_JSON")

    if [ -z "$digest" ] || [ "$digest" = "null" ]; then
        echo "[$deb_arch] error: no digest found for asset $asset" >&2
        return 1
    fi

    sed -i "s/version = \"[^\"]*\"/version = \"$LATEST_VERSION\"/" "$package_nix"
    sed -i "s|hash = \"[^\"]*\"|hash = \"$digest\"|" "$package_nix"

    echo "[$deb_arch] updated $(basename "$package_nix") to $LATEST_VERSION ($digest)"
}

update_package "$SCRIPT_DIR/package-x86_64.nix" amd64
update_package "$SCRIPT_DIR/package-aarch64.nix" arm64
