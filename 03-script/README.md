# 03 - Bash script

Simplest method: SSH to each node in parallel and run `crictl pull`.

## Usage

```bash
# all nodes (names from `kubectl get nodes`)
./prepull.sh registry.example.com/myapp:1.2.3

# only some nodes
./prepull.sh registry.example.com/myapp:1.2.3 worker01 worker03
```

Environment variables:
```bash
SSH_USER=ubuntu ./prepull.sh IMAGE worker01     # login as another user
SSH_OPTS="-i ~/.ssh/k8s -o StrictHostKeyChecking=no" ./prepull.sh IMAGE
```

## Requirements
- `kubectl` access (only when you do not list nodes)
- SSH access to nodes with passwordless sudo
- Node names must resolve over SSH (DNS or ~/.ssh/config). If they do not, pass IPs as arguments.

## Notes
- Exit code is 1 if any node failed. Logs are in a temp folder printed on failure.
- Control-plane nodes are included when you use "all nodes". List workers by name to skip them.
