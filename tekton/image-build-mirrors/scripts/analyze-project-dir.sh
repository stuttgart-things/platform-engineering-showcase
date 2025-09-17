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
[ -n "$DOCKERFILE" ] || DOCKERFILE="$TARGET_DIR/Dockerfile"
[ -n "$REQ_FILE" ] || REQ_FILE="$TARGET_DIR/requirements.txt"

# Existence checks
if [ ! -f "$DOCKERFILE" ]; then
  echo "❌ No Dockerfile found: $DOCKERFILE"
  exit 1
fi
if [ ! -f "$REQ_FILE" ]; then
  echo "❌ No requirements.txt found: $REQ_FILE"
  exit 1
fi

# Temp file for Dockerfile with continuations joined
TMP=$(mktemp /tmp/analyze.XXXXXX)
trap 'rm -f "$TMP"' EXIT

# Join lines that end with backslash so multi-line apk/pip commands become single lines
# This converts:
# RUN apk add ... \
#     pkg1 \
#     pkg2
# into a single line containing all tokens.
sed -e ':a' -e '/\\$/ { N; s/\\\n[[:space:]]*/ /; ba }' "$DOCKERFILE" > "$TMP"

# --- pip packages ---------------------------------------------------
# from requirements.txt (strip comments / blank lines)
REQ_PACKAGES=$(grep -vE '^[[:space:]]*#' "$REQ_FILE" | grep -vE '^[[:space:]]*$' || true)

# from Dockerfile: find pip install lines, remove everything up to "install", split tokens,
# filter out flags (-*, --*, paths like /requirements.txt)
DOCKER_PIP_RAW=$(
  grep -i 'pip[0-9]*[[:space:]]*install' "$TMP" || true
)
DOCKER_PIP=$(
  printf "%s\n" "$DOCKER_PIP_RAW" | \
  sed -E 's/.*pip[0-9]*[[:space:]]*install[[:space:]]*//' | \
  tr ' ' '\n' | \
  grep -vE '^$' | \
  grep -vE '^-' | \
  grep -vE '/|requirements\.txt' || true
)

# Merge + dedupe pip packages
ALL_PIP=$(printf "%s\n%s\n" "$REQ_PACKAGES" "$DOCKER_PIP" | sed '/^[[:space:]]*$/d' | sort -u || true)
ALL_PIP_CSV=$(printf "%s\n" "$ALL_PIP" | tr '\n' ',' | sed 's/,$//')

# --- apk packages ---------------------------------------------------
# find apk add lines (after joining continuations), remove everything up to "add",
# split, filter out flags and empty tokens.
DOCKER_APK_RAW=$(
  grep -i 'apk[[:space:]]*.*add' "$TMP" || true
)
DOCKER_APK=$(
  printf "%s\n" "$DOCKER_APK_RAW" | \
  sed -E 's/.*add[[:space:]]*//' | \
  tr ' ' '\n' | \
  grep -vE '^$' | \
  grep -vE '^-' || true
)

ALL_APK=$(printf "%s\n" "$DOCKER_APK" | sed '/^[[:space:]]*$/d' | sort -u || true)
ALL_APK_CSV=$(printf "%s\n" "$ALL_APK" | tr '\n' ',' | sed 's/,$//')

# ---------- Pretty output ----------
echo ""
echo "📦 Detected dependencies in project: $TARGET_DIR"
echo ""

echo "🐍 Pip packages (from $REQ_FILE + inline pip installs in $DOCKERFILE):"
echo "----------------------------------------"
if [ -n "$ALL_PIP" ]; then
  echo "--pip-packages \"${ALL_PIP_CSV}\""
  echo ""
  echo "List:"
  printf "%s\n" "$ALL_PIP" | sed -e 's/^/  - /'
else
  echo "  (none found)"
fi
echo ""

echo "🐧 APK packages (from $DOCKERFILE):"
echo "----------------------------------------"
if [ -n "$ALL_APK" ]; then
  echo "--apk-packages \"${ALL_APK_CSV}\""
  echo ""
  echo "List:"
  printf "%s\n" "$ALL_APK" | sed -e 's/^/  - /'
else
  echo "  (none found)"
fi
echo ""
