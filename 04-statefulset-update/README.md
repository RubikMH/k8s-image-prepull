# 04 - StatefulSet update (canary)

Run this AFTER the image is pre-pulled (folders 01, 02 or 03).

## How it works
A StatefulSet updates from the highest ordinal to the lowest (2, 1, 0) and waits for each pod to be Ready.
`partition: N-1` means only the last pod updates first. After you check it, `partition: 0` updates the rest.

## Usage
```bash
./update.sh myapp myapp registry.example.com/myapp:1.2.3
./update.sh myapp myapp registry.example.com/myapp:1.2.3 production   # other namespace
```
Arguments: StatefulSet name, container name, image, optional namespace.

If the canary is bad, answer `N` and roll back:
```bash
kubectl rollout undo sts/myapp
```
Note: with a partition set, pods below the partition are never touched, so rollback is limited to the canary pod.

## Files
- `update.sh` - canary update script
- `statefulset-snippet.yaml` - probes, preStop, PDB and other settings that reduce downtime

## Honest note about downtime
With 1 replica there is always a short downtime (old pod stops, new pod with the same name starts).
Pre-pull removes the image download time, but not the stop/start time.
For near-zero downtime use 2+ replicas and a correct readinessProbe.
