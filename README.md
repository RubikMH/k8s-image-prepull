# prepull-kit

Pre-pull a new container image on your Kubernetes nodes BEFORE updating a StatefulSet,
so the rollout does not wait for the image download. This cuts downtime.

| Folder | Method | Pick it when |
|---|---|---|
| `01-ansible` | Ansible playbook, `crictl pull` over SSH | You already use Ansible. Easy to choose nodes with `--limit`. |
| `02-daemonset-labels` | DaemonSet + node label | You want everything inside Kubernetes, no SSH. |
| `03-script` | One bash script | Quick and simple, no extra tools. |
| `04-statefulset-update` | Canary update with `partition` | Do this AFTER pre-pull, to update safely. |

## Recommended flow

1. Find where the pods run: `kubectl get pods -l app=myapp -o wide`
2. Pre-pull with ONE of methods 01, 02, 03 (all nodes, or only some).
3. Update with `04-statefulset-update/update.sh` (canary first, then the rest).

## Which nodes?

- **Local PV (pod pinned to a node):** pre-pull only on that pod's node.
- **Network storage (Ceph, NFS), no nodeSelector:** pre-pull on ALL nodes.
- **Network storage + nodeSelector/affinity:** pre-pull on the labeled nodes only.

## Important

- Use a fixed tag (never `latest`) and `imagePullPolicy: IfNotPresent` in the StatefulSet.
- Examples use `registry.example.com/myapp:1.2.3`, `sts/myapp`, label `app=myapp`. Change them.
- Nodes must use containerd (`crictl`). For Docker nodes use `docker pull` instead.
