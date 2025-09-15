#!/bin/sh
set -eu

ZIP_PATH=""
PVC_PATH=""
RUNTIME="local"
FORCE=false

usage() {
  echo "Usage: $0 --zip-path <file.zip> --pvc-path <dir> [--runtime local|docker|podman] [--force]"
  exit 1
}

# Parse flags
while [ $# -gt 0 ]; do
  case "$1" in
    --zip-path)
      ZIP_PATH="$2"
      shift 2
      ;;
    --pvc-path)
      PVC_PATH="$2"
      shift 2
      ;;
    --runtime)
      RUNTIME="$2"
      shift 2
      ;;
    --force)
      FORCE=true
      shift 1
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

if [ -z "$ZIP_PATH" ] || [ -z "$PVC_PATH" ]; then
  echo "[ERROR] --zip-path and --pvc-path are required"
  usage
fi

echo "[INFO] Unzipping $ZIP_PATH to $PVC_PATH"

mkdir -p "$PVC_PATH"

UNZIP_FLAGS=""
if [ "$FORCE" = true ]; then
  UNZIP_FLAGS="-o"
fi

if [ "$RUNTIME" = "local" ]; then
  unzip $UNZIP_FLAGS "$ZIP_PATH" -d "$PVC_PATH"
else
  echo "[INFO] Running unzip in $RUNTIME container"
  $RUNTIME run --rm -v "$ZIP_PATH:/tmp/archive.zip" -v "$PVC_PATH:/data" alpine:latest sh -c "
    apk add --no-cache unzip >/dev/null
    unzip $UNZIP_FLAGS /tmp/archive.zip -d /data
  "
fi

echo "[INFO] Done."
