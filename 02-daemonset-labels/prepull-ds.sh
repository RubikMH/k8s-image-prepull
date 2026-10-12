#!/usr/bin/env bash
# usage:
#   ./prepull-ds.sh start IMAGE [node1 node2 ...]   (no nodes = all nodes)
#   ./prepull-ds.sh status
#   ./prepull-ds.sh clean
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
NS="${NS:-default}"
DS=prepull-myapp

case "${1:-}" in
  start)
    IMAGE="${2:?image required}"; shift 2
    NODES=("$@")
    if [ ${#NODES[@]} -eq 0 ]; then
      kubectl label node --all prepull=true --overwrite
    else
      kubectl label node "${NODES[@]}" prepull=true --overwrite
    fi
    sed "s#IMAGE_PLACEHOLDER#${IMAGE}#" "$DIR/daemonset.yaml" | kubectl -n "$NS" apply -f -
    echo "Started. Check with: $0 status"
    ;;
  status)
    # The image is cached when the init container has an imageID.
    # (Distroless images have no shell, so the pod may show Init:Error, but the image is still pulled.)
    kubectl -n "$NS" get pods -l app=$DS -o custom-columns=\
POD:.metadata.name,NODE:.spec.nodeName,PHASE:.status.phase,IMAGEID:.status.initContainerStatuses[0].imageID
    ;;
  clean)
    kubectl -n "$NS" delete ds $DS --ignore-not-found
    kubectl label node --all prepull- || true
    echo "Cleaned. (The image stays cached on the nodes.)"
    ;;
  *)
    sed -n '2,6p' "$0"; exit 1;;
esac
