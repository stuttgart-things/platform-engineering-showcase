#!/bin/sh
set -eu

# Default values
IMAGE=""
APK_PACKAGES=""
APK_REPO="main"
RUNTIME="docker"
OUTPUT_DIR="/tmp"
ARCHIVE_NAME="apk-packages"

usage() {
  echo "Usage: $0 --image <image> --apk-packages <pkg1,pkg2,...> [--apk-repo main|community|testing] [--runtime docker|podman] [--output-dir DIR] [--archive-name NAME]"
  echo ""
  echo "Options:"
  echo "  --image          Alpine-based Docker image (required)"
  echo "  --apk-packages   Comma-separated list of APK packages (required)"
  echo "  --apk-repo       Alpine repository: main, community, testing (default: main)"
  echo "  --runtime        Container runtime: docker or podman (default: docker)"
  echo "  --output-dir     Output directory for archive (default: /tmp)"
  echo "  --archive-name   Name of the archive file (default: apk-packages)"
  echo ""
  echo "Examples:"
  echo "  $0 --image python:3.13.7-alpine --apk-packages chromium --apk-repo community"
  echo "  $0 --image alpine:3.18 --apk-packages curl,wget --apk-repo main"
  exit 1
}

# Parse flags
while [ $# -gt 0 ]; do
  case "$1" in
    --image)
      IMAGE="$2"
      shift 2
      ;;
    --apk-packages)
      APK_PACKAGES="$2"
      shift 2
      ;;
    --apk-repo)
      APK_REPO="$2"
      shift 2
      ;;
    --runtime)
      RUNTIME="$2"
      shift 2
      ;;
    --output-dir)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --archive-name)
      ARCHIVE_NAME="$2"
      shift 2
      ;;
    --help|-h)
      usage
      ;;
    *)
      echo "Unknown option: $1"
      usage
      ;;
  esac
done

if [ -z "$IMAGE" ] || [ -z "$APK_PACKAGES" ]; then
  echo "[ERROR] --image and --apk-packages are required"
  usage
fi

# Validate repository
case "$APK_REPO" in
  main|community|testing)
    ;;
  *)
    echo "[ERROR] Invalid repository '$APK_REPO'. Must be one of: main, community, testing"
    exit 1
    ;;
esac

# STEP 1: Get Alpine VERSION_ID from base image
VERSION_ID=$($RUNTIME run --rm "$IMAGE" sh -c \
  "grep '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '\"' | cut -d. -f1,2")
echo "[INFO] Alpine VERSION_ID: ${VERSION_ID}"
echo "[INFO] Using repository: ${APK_REPO}"

# STEP 2: Prepare local mirror dir
WORK_DIR="$(pwd)/apk"
MIRROR_DIR="${WORK_DIR}/v${VERSION_ID}/${APK_REPO}/x86_64"
rm -rf "$WORK_DIR"
mkdir -p "$MIRROR_DIR"

# Convert commas to spaces for APK
APK_PACKAGES_SPACE=$(echo "$APK_PACKAGES" | tr ',' ' ')

# STEP 3: Run container and fetch APK packages
$RUNTIME run --rm \
  -e VERSION_ID="$VERSION_ID" \
  -e APK_REPO="$APK_REPO" \
  -e APK_PACKAGES="$APK_PACKAGES_SPACE" \
  -v "$MIRROR_DIR:/mirror" \
  "$IMAGE" sh -euxc "
    cd /mirror
    echo \"[INFO] Using Alpine v\$VERSION_ID repository: \$APK_REPO\"

    # Configure repositories - add both main and the specified repo if it's not main
    if [ \"\$APK_REPO\" = \"main\" ]; then
      echo \"http://dl-cdn.alpinelinux.org/alpine/v\$VERSION_ID/main\" > /etc/apk/repositories
    else
      # For community/testing, we typically need main as well for dependencies
      echo \"http://dl-cdn.alpinelinux.org/alpine/v\$VERSION_ID/main\" > /etc/apk/repositories
      echo \"http://dl-cdn.alpinelinux.org/alpine/v\$VERSION_ID/\$APK_REPO\" >> /etc/apk/repositories
    fi

    echo \"[INFO] Repository configuration:\"
    cat /etc/apk/repositories

    apk update
    echo \"[INFO] Fetching APK_PACKAGES: \$APK_PACKAGES\"
    apk fetch --recursive --output . \$APK_PACKAGES

    echo \"[INFO] Fetching APKINDEX for \$APK_REPO repository\"
    wget -q http://dl-cdn.alpinelinux.org/alpine/v\$VERSION_ID/\$APK_REPO/x86_64/APKINDEX.tar.gz

    # Also fetch main APKINDEX if we're not using main repo (for dependencies)
    if [ \"\$APK_REPO\" != \"main\" ]; then
      echo \"[INFO] Also fetching main APKINDEX for dependencies\"
      wget -q -O APKINDEX-main.tar.gz http://dl-cdn.alpinelinux.org/alpine/v\$VERSION_ID/main/x86_64/APKINDEX.tar.gz
    fi
  "

echo "[INFO] APK packages and index saved under: $MIRROR_DIR"

# STEP 4: Zip
cd "$WORK_DIR"
zip -r "${OUTPUT_DIR}/${ARCHIVE_NAME}.zip" .
cd ..

# STEP 5: Cleanup
rm -rf "$WORK_DIR"

echo "[INFO] Archive created: ${OUTPUT_DIR}/${ARCHIVE_NAME}.zip"
