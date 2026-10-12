# 02 - DaemonSet + node labels

A DaemonSet runs a pod on every node that has the label `prepull=true`.
Its init container uses your new image, so kubelet pulls the image on those nodes.
The pod itself does nothing (a `pause` container).

## Files
- `daemonset.yaml` - the DaemonSet (image is filled in by the script)
- `prepull-ds.sh` - helper: start / status / clean

## Usage

```bash
# only some nodes
./prepull-ds.sh start registry.example.com/myapp:1.2.3 worker01 worker03

# all nodes
./prepull-ds.sh start registry.example.com/myapp:1.2.3

# watch progress (IMAGEID filled = image is cached on that node)
./prepull-ds.sh status

# when finished
./prepull-ds.sh clean
```

Use another namespace: `NS=prod ./prepull-ds.sh start ...`

## Notes
- If the pod uses an imagePullSecret, add the same `imagePullSecrets` to `daemonset.yaml`.
- Pulled images stay cached after `clean` (until the kubelet garbage collector removes unused images when disk is low).
- If you also want the StatefulSet to run ONLY on these nodes, add `nodeSelector: {prepull: "true"}`
  to it and do NOT run `clean` until the update is done.
- The `tolerations` block lets the DaemonSet run on tainted nodes. Remove it if you do not want that.
