#!/bin/sh
set -eu

# Default values
IMAGE=""
PIP_PACKAGES=""
RUNTIME="docker"
OUTPUT_DIR="/tmp"
ARCHIVE_NAME="pip-packages"

usage() {
  echo "Usage: $0 --image <image> --pip-packages <pkg1,pkg2,...> [--runtime docker|podman] [--output-dir DIR] [--archive-name NAME]"
  exit 1
}

# Parse flags
while [ $# -gt 0 ]; do
  case "$1" in
    --image)
      IMAGE="$2"
      shift 2
      ;;
    --pip-packages)
      PIP_PACKAGES="$2"
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

if [ -z "$IMAGE" ] || [ -z "$PIP_PACKAGES" ]; then
  echo "[ERROR] --image and --pip-packages are required"
  usage
fi

# Convert commas → spaces for pip
PIP_PACKAGES_SPACE=$(echo "$PIP_PACKAGES" | tr ',' ' ')

# Local directory on host
WHEELHOUSE="$(pwd)/wheelhouse"
rm -rf "$WHEELHOUSE" || true
mkdir -p "$WHEELHOUSE"

# Run container to build offline wheelhouse
$RUNTIME run --rm \
  -v "$WHEELHOUSE:/wheelhouse" \
  "$IMAGE" sh -euxc "
    # 1. Create and activate venv
    python3 -m venv /venv
    . /venv/bin/activate

    # 2. Upgrade pip tooling
    pip install --upgrade pip setuptools wheel

    # 3. Download requested packages into /wheelhouse
    pip download -d /wheelhouse $PIP_PACKAGES_SPACE

    # 4. Optional: install them (from wheelhouse, offline style)
    pip install --no-index --find-links=/wheelhouse $PIP_PACKAGES_SPACE

    # 5. Record installed packages
    pip freeze > /wheelhouse/installed-packages.txt
  "

echo "[INFO] pip packages and wheelhouse saved under: $WHEELHOUSE"

# STEP 4: Zip
cd wheelhouse
zip -r "${OUTPUT_DIR}/pip-${ARCHIVE_NAME}.zip" .
cd ..

echo "[INFO] Created ${OUTPUT_DIR}/pip-${ARCHIVE_NAME}.zip"
echo "[INFO] Done."

rm -rf "$WHEELHOUSE"
