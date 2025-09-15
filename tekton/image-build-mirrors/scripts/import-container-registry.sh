#!/bin/bash
set -eux

# Default values
POD_NAME="skopeo"
IMAGE="bdwyertech/skopeo:1.16.1"
CLEANUP=true

# Required variables (no default)
TAR_FILE=""
TARGET_REGISTRY=""
NAMESPACE=""
TARGET_IMAGE=""
REG_USERNAME=""
REG_PASSWORD=""

usage() {
  echo "Usage: $0 --tar-file <file.tar> --target-registry <registry> --namespace <ns> --target-image <image> --username <user> --password <pass> [--pod-name <name>] [--image <skopeo-image>] [--no-cleanup]"
  exit 1
}

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tar-file)
      TAR_FILE="$2"
      shift 2
      ;;
    --target-registry)
      TARGET_REGISTRY="$2"
      shift 2
      ;;
    --namespace)
      NAMESPACE="$2"
      shift 2
      ;;
    --target-image)
      TARGET_IMAGE="$2"
      shift 2
      ;;
    --username)
      REG_USERNAME="$2"
      shift 2
      ;;
    --password)
      REG_PASSWORD="$2"
      shift 2
      ;;
    --pod-name)
      POD_NAME="$2"
      shift 2
      ;;
    --image)
      IMAGE="$2"
      shift 2
      ;;
    --no-cleanup)
      CLEANUP=false
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

# Validate required
if [[ -z "$TAR_FILE" || -z "$TARGET_REGISTRY" || -z "$NAMESPACE" || -z "$TARGET_IMAGE" || -z "$REG_USERNAME" || -z "$REG_PASSWORD" ]]; then
  echo "[ERROR] Missing required arguments"
  usage
fi

TAR_FILE_NAME=$(basename "$TAR_FILE")

# Optional cleanup
if $CLEANUP; then
  kubectl -n "$NAMESPACE" delete pod "$POD_NAME" || true
fi

echo "[INFO] Starting ephemeral Skopeo pod: $POD_NAME"
kubectl -n "$NAMESPACE" run "$POD_NAME" \
  --image="$IMAGE" \
  --restart=Never \
  --overrides='
{
  "spec": {
    "containers": [{
      "name": "skopeo",
      "image": "'"$IMAGE"'",
      "stdin": true,
      "tty": true,
      "securityContext": { "runAsUser": 0 }
    }]
  }
}' \
  --stdin --tty --attach &

sleep 5

echo "[INFO] Copying TAR file into pod"
kubectl -n "$NAMESPACE" cp "$TAR_FILE" "$POD_NAME:/tmp/$TAR_FILE_NAME"

echo "[INFO] Pushing image with Skopeo"
kubectl -n "$NAMESPACE" exec -it "$POD_NAME" -- sh -c "
  skopeo login -u ${REG_USERNAME} -p ${REG_PASSWORD} ${TARGET_REGISTRY} --tls-verify=false
  skopeo copy docker-archive:/tmp/$TAR_FILE_NAME docker://${TARGET_REGISTRY}/${TARGET_IMAGE} --tls-verify=false
"

if $CLEANUP; then
  echo "[INFO] Cleaning up ephemeral pod"
  kubectl -n "$NAMESPACE" delete pod "$POD_NAME" || true
fi

echo "[INFO] Done."
