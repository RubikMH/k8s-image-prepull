# 01 - Ansible

Pulls the image on the nodes with `crictl pull`, then checks it is cached.

## Files
- `prepull.yml` - the playbook
- `inventory.example.ini` - copy to `inventory.ini` and edit your nodes

## Usage

All nodes in the `workers` group:
```bash
ansible-playbook -i inventory.ini prepull.yml -e image=registry.example.com/myapp:1.2.3
```

Only some nodes:
```bash
ansible-playbook -i inventory.ini prepull.yml -e image=registry.example.com/myapp:1.2.3 --limit worker01,worker03
```

Another group (for example the control plane too):
```bash
ansible-playbook -i inventory.ini prepull.yml -e image=... -e target=all
```

Change parallelism (default 10 nodes at once): `-e parallel=3`

## Notes
- Needs SSH access and sudo on the nodes.
- Private registry: log in first, or pass credentials: `crictl pull --creds user:pass IMAGE`
  (better to keep credentials in ansible-vault).
