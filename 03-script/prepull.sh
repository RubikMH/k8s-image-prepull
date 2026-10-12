#!/usr/bin/env bash
# usage: ./prepull.sh IMAGE [node1 node2 ...]   (no nodes = all nodes)
# env:   SSH_USER (default: current user), SSH_OPTS
set -uo pipefail
IMAGE="${1:?usage: $0 IMAGE [node ...]}"; shift
if [ $# -gt 0 ]; then
  NODES=("$@")
else
  read -r -a NODES <<< "$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}')"
fi
USER_PREFIX="${SSH_USER:+$SSH_USER@}"
LOG=$(mktemp -d)

for n in "${NODES[@]}"; do
  (
    if ssh ${SSH_OPTS:-} "${USER_PREFIX}${n}" "sudo crictl pull '$IMAGE'" >"$LOG/$n.log" 2>&1; then
      echo "OK    $n"
    else
      echo "FAIL  $n  (see $LOG/$n.log)"; touch "$LOG/$n.fail"
    fi
  ) &
done
wait

if ls "$LOG"/*.fail >/dev/null 2>&1; then
  echo "Some nodes failed."; exit 1
fi
echo "Image cached on ${#NODES[@]} node(s)."
