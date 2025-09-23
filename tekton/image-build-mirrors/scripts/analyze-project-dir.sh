#!/bin/sh
# POSIX sh script
set -eu

show_help() {
  cat <<EOF
Usage: $0 [OPTIONS]

Options:
  --dir DIR            Target directory (default: .)
  --dockerfile FILE    Dockerfile name (default: Dockerfile inside --dir)
  --requirements FILE  Requirements file (default: requirements.txt inside --dir)
  --help               Show this help message and exit

Example:
  $0 --dir _example
EOF
}

# Defaults
TARGET_DIR="."
DOCKERFILE=""
REQ_FILE=""

# Parse flags (simple)
while [ $# -gt 0 ]; do
  case "$1" in
    --dir) TARGET_DIR="$2"; shift 2 ;;
    --dockerfile) DOCKERFILE="$2"; shift 2 ;;
    --requirements) REQ_FILE="$2"; shift 2 ;;
    --help) show_help; exit 0 ;;
    *) echo "❌ Unknown option: $1"; show_help; exit 1 ;;
  esac
done

# Resolve defaults
if [ -z "$DOCKERFILE" ]; then
  DOCKERFILE="$TARGET_DIR/Dockerfile"
fi

if [ -z "$REQ_FILE" ]; then
  REQ_FILE="$TARGET_DIR/requirements.txt"
fi

# Existence checks
if [ ! -f "$DOCKERFILE" ]; then
  echo "❌ No Dockerfile found: $DOCKERFILE"
  exit 1
fi

if [ ! -f "$REQ_FILE" ]; then
  echo "❌ No requirements.txt found: $REQ_FILE"
  exit 1
fi

# Temp file for Dockerfile with continuations joined and comments removed
TMP=$(mktemp /tmp/analyze.XXXXXX)
trap 'rm -f "$TMP"' EXIT

# Join lines that end with backslash and remove comments
sed -e 's/#.*//' -e ':a' -e '/\\$/ { N; s/\\\n[[:space:]]*/ /; ba }' "$DOCKERFILE" > "$TMP"

# --- pip packages ---------------------------------------------------
# from requirements.txt (strip comments / blank lines)
REQ_PACKAGES=$(grep -vE '^[[:space:]]*#' "$REQ_FILE" | tr -d '\r' | grep -vE '^[[:space:]]*$' || true)

# from Dockerfile: find pip install lines
DOCKER_PIP_RAW=$(grep -i 'pip[0-9]*[[:space:]]*install' "$TMP" || true)

DOCKER_PIP=$(
  echo "$DOCKER_PIP_RAW" |
  sed -E 's/^[[:space:]]*RUN[[:space:]]+//i' |
  sed -E 's/.*pip[0-9]*[[:space:]]+install[[:space:]]+//i' |
  tr -s ' ' | tr ' ' '\n' |
  grep -vE '^(--.*|-.*|\\.*|\(|\)|/.*|requirements\.txt|`|"|'"'"'|&&|\|\|)' |
  grep -vE '^[[:space:]]*$' || true
)

# Merge + dedupe pip packages
ALL_PIP=$(printf "%s\n%s\n" "$REQ_PACKAGES" "$DOCKER_PIP" | sed '/^[[:space:]]*$/d' | sort -u | xargs -n1 | sort -u || true)
ALL_PIP_CSV=$(echo "$ALL_PIP" | tr '\n' ',' | sed 's/,$//')

# --- apk packages ---------------------------------------------------
DOCKER_APK_RAW=$(grep -i 'apk.*add' "$TMP" || true)

DOCKER_APK=$(
  echo "$DOCKER_APK_RAW" |
  sed -E 's/^[[:space:]]*RUN[[:space:]]+//i' |
  sed -E 's/.*apk[[:space:]]+.*add[[:space:]]+//i' |
  tr -s ' ' | tr ' ' '\n' |
  grep -vE '^(--.*|-.*|\\.*|\(|\)|/.*|`|"|'"'"'|&&|\|\|)' |
  grep -vE '^[[:space:]]*$' || true
)

ALL_APK=$(echo "$DOCKER_APK" | sed '/^[[:space:]]*$/d' | sort -u | xargs -n1 | sort -u || true)
ALL_APK_CSV=$(echo "$ALL_APK" | tr '\n' ',' | sed 's/,$//')

# ---------- Pretty output ----------
echo ""
echo "📦 Detected dependencies in project: $TARGET_DIR"
echo ""

echo "🐍 Pip packages (from $REQ_FILE + inline pip installs in $DOCKERFILE):"
echo "----------------------------------------"
if [ -n "$ALL_PIP" ]; then
  echo "--pip-packages \"$ALL_PIP_CSV\""
  echo ""
  echo "List:"
  echo "$ALL_PIP" | sed -e 's/^/  - /'
else
  echo "  (none found)"
fi
echo ""

echo "🐧 APK packages (from $DOCKERFILE):"
echo "----------------------------------------"
if [ -n "$ALL_APK" ]; then
  echo "--apk-packages \"$ALL_APK_CSV\""
  echo ""
  echo "List:"
  echo "$ALL_APK" | sed -e 's/^/  - /'
else
  echo "  (none found)"
fi
echo ""
