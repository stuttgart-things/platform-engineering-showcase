#!/bin/sh
set -eu

# Default namespace
NAMESPACE="default"

# Parse flags
while [ $# -gt 0 ]; do
  case "$1" in
    -n|--namespace)
      NAMESPACE="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [-n|--namespace NAMESPACE]"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [-n|--namespace NAMESPACE]"
      exit 1
      ;;
  esac
done

# Get all container images including init containers, comma-separated
kubectl get pods -n "$NAMESPACE" -o json | \
jq -r '
  [.items[] | (.spec.containers[]?.image, .spec.initContainers[]?.image)]
  | unique
  | join(",")
'
