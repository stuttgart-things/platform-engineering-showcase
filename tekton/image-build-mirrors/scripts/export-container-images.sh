#!/bin/sh
set -eux

# Defaults
OUTPUT_DIR="/tmp"
ZIP_NAME="container-images"

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --images)
      IMAGES="$2"
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
      ZIP_NAME="$2"
      shift 2
      ;;
    --help)
      echo "Usage: $0 --images <list> --runtime <docker|ctr> [--output-dir <dir>] [--archive-name <name>]"
      exit 0
      ;;
    *)
      echo "[ERROR] Unknown argument: $1"
      exit 1
      ;;
  esac
done

# Validate required args
if [ -z "${IMAGES:-}" ] || [ -z "${RUNTIME:-}" ]; then
  echo "[ERROR] --images and --runtime are required"
  exit 1
fi

ZIP_PATH="$OUTPUT_DIR/$ZIP_NAME.zip"
OUTDIR="$OUTPUT_DIR/tmp-images"

rm -rf "$OUTDIR" || true
rm -rf "$ZIP_PATH" || true

mkdir -p "$OUTDIR"

IMAGES_LIST=$(echo "$IMAGES" | tr ',' ' ')

for IMAGE in $IMAGES_LIST; do
    echo "[INFO] Processing $IMAGE"

    # Sanitize image name for tar filename (replace / and : with _)
    SAFE_NAME=$(echo "$IMAGE" | sed 's#[/:]#_#g')
    TAR_PATH="$OUTDIR/${SAFE_NAME}.tar"

    if [ "$RUNTIME" = "docker" ]; then
        if docker image inspect "$IMAGE" >/dev/null 2>&1; then
            echo "[INFO] Image already present locally: $IMAGE"
        else
            echo "[INFO] Pulling with Docker: $IMAGE"
            docker pull "$IMAGE"
        fi

        echo "[INFO] Saving $IMAGE to $TAR_PATH"
        docker save -o "$TAR_PATH" "$IMAGE"

    elif [ "$RUNTIME" = "ctr" ]; then
        echo "[INFO] Pulling with containerd (ctr): $IMAGE"
        sudo ctr --address /run/k3s/containerd/containerd.sock --namespace k8s.io images pull "$IMAGE"

        echo "[INFO] Exporting $IMAGE to $TAR_PATH"
        sudo ctr --address /run/k3s/containerd/containerd.sock --namespace k8s.io images export "$TAR_PATH" "$IMAGE"

    else
        echo "[ERROR] Unsupported runtime: $RUNTIME"
        exit 1
    fi
done

echo "[INFO] Creating archive $ZIP_PATH"
cd "$OUTDIR"
zip -r "$ZIP_PATH" ./*.tar

echo "[INFO] Done. Archive at $ZIP_PATH"
rm -rf "$OUTDIR" || true
