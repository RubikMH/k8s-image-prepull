#!/usr/bin/env bash
# Canary update of a StatefulSet.
# usage: ./update.sh STS_NAME CONTAINER_NAME IMAGE [NAMESPACE]
set -euo pipefail
STS="${1:?sts name}"; CONT="${2:?container name}"; IMAGE="${3:?image}"; NS="${4:-default}"

REPLICAS=$(kubectl -n "$NS" get sts "$STS" -o jsonpath='{.spec.replicas}')
echo "StatefulSet $STS has $REPLICAS replica(s)."

if [ "$REPLICAS" -gt 1 ]; then
  # Canary: only the highest ordinal is updated first
  kubectl -n "$NS" patch sts "$STS" -p \
    "{\"spec\":{\"updateStrategy\":{\"type\":\"RollingUpdate\",\"rollingUpdate\":{\"partition\":$((REPLICAS-1))}}}}"
fi

kubectl -n "$NS" set image sts/"$STS" "$CONT=$IMAGE"

if [ "$REPLICAS" -gt 1 ]; then
  echo "Waiting for canary pod $STS-$((REPLICAS-1)) ..."
  kubectl -n "$NS" wait --for=condition=Ready pod/"$STS-$((REPLICAS-1))" --timeout=300s
  echo "Canary is Ready. Check logs/metrics now:"
  echo "  kubectl -n $NS logs $STS-$((REPLICAS-1))"
  read -r -p "Continue with the rest? [y/N] " ans
  [ "$ans" = "y" ] || { echo "Stopped. Rollback: kubectl -n $NS rollout undo sts/$STS"; exit 1; }
  kubectl -n "$NS" patch sts "$STS" -p '{"spec":{"updateStrategy":{"rollingUpdate":{"partition":0}}}}'
fi

kubectl -n "$NS" rollout status sts/"$STS" --timeout=900s
echo "Done."
