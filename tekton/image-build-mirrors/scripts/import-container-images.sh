#!/bin/sh
set -eux

# Defaults
INPUT_DIR="/tmp"
ZIP_NAME="container-images"

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --runtime)
      RUNTIME="$2"
      shift 2
      ;;
    --input-dir)
      INPUT_DIR="$2"
      shift 2
      ;;
    --archive-name)
      ZIP_NAME="$2"
      shift 2
      ;;
    --help)
      echo "Usage: $0 --runtime <docker|ctr> [--input-dir <dir>] [--archive-name <name>]"
      exit 0
      ;;
    *)
      echo "[ERROR] Unknown argument: $1"
      exit 1
      ;;
  esac
done

# Validate required args
if [ -z "${RUNTIME:-}" ]; then
  echo "[ERROR] --runtime is required"
  exit 1
fi

ZIP_PATH="$INPUT_DIR/$ZIP_NAME.zip"
OUTDIR="$INPUT_DIR/tmp-images"

if [ ! -f "$ZIP_PATH" ]; then
  echo "[ERROR] Archive not found: $ZIP_PATH"
  exit 1
fi

rm -rf "$OUTDIR" || true
mkdir -p "$OUTDIR"

echo "[INFO] Extracting archive $ZIP_PATH"
unzip -q "$ZIP_PATH" -d "$OUTDIR"

for TAR_PATH in "$OUTDIR"/*.tar; do
    echo "[INFO] Importing $(basename "$TAR_PATH")"

    if [ "$RUNTIME" = "docker" ]; then
        docker load -i "$TAR_PATH"

    elif [ "$RUNTIME" = "ctr" ]; then
        sudo ctr --address /run/k3s/containerd/containerd.sock --namespace k8s.io images import "$TAR_PATH"

    else
        echo "[ERROR] Unsupported runtime: $RUNTIME"
        exit 1
    fi
done

echo "[INFO] Done importing images."
rm -rf "$OUTDIR" || true
