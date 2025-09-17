#!/bin/sh
set -eu

# Default values
NAME=""
CHARTURL=""
VERSION=""

# Parse flags
while [ $# -gt 0 ]; do
  case "$1" in
    --name) NAME="$2"; shift 2 ;;
    --charturl) CHARTURL="$2"; shift 2 ;;
    --version) VERSION="$2"; shift 2 ;;
    *) echo "Unknown flag: $1"; exit 1 ;;
  esac
done

# Validate required flags
if [ -z "$NAME" ] || [ -z "$CHARTURL" ] || [ -z "$VERSION" ]; then
  echo "Usage: $0 --name <name> --charturl <chart_url> --version <version>"
  exit 1
fi

# Create temp dir
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Download Helm chart
echo "Downloading Helm chart $NAME ($VERSION) from $CHARTURL ..."
helm pull "$CHARTURL" --version "$VERSION" --destination "$TMPDIR"

# Extract chart name from .tgz
CHART_TGZ=$(ls "$TMPDIR"/*.tgz)
mkdir -p "$TMPDIR/chart"
tar -xzf "$CHART_TGZ" -C "$TMPDIR/chart" --strip-components=1

# Scan for images and output comma-separated list without leading comma
IMAGES=$(helm template "$TMPDIR/chart" \
  | grep -E 'image:' \
  | sed 's/^[[:space:]]*image:[[:space:]]*["]*//; s/["]*$//' \
  | grep -v '^$' \
  | sort -u \
  | paste -sd ',' -)

echo "$IMAGES"
