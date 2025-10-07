#!/bin/bash
set -e

echo "⚡ Setting up NFS Server Permissions for Open WebUI"

NFS_SERVER="10.0.0.134"
BASE="/data/app1/openwebui"
MODELS="$BASE/models"
CONFIG="$BASE/config"
LOGS="$BASE/logs"

ssh root@$NFS_SERVER bash -s <<'EOF'
set -e

BASE="/data/app1/openwebui"
MODELS="$BASE/models"
CONFIG="$BASE/config"
LOGS="$BASE/logs"

# Create directories
mkdir -p "$MODELS" "$CONFIG" "$LOGS"

# Set ownership and permissions
# Assume UID/GID 1000 for Open WebUI container
chown -R 1000:1000 "$MODELS" "$CONFIG" "$LOGS"
chmod 770 "$MODELS" "$CONFIG" "$LOGS"
chmod g+s "$MODELS" "$CONFIG" "$LOGS"

# Optional: set default ACLs if setfacl is available
if command -v setfacl >/dev/null 2>&1; then
  setfacl -d -m u:1000:rwx "$MODELS" "$CONFIG" "$LOGS"
  setfacl -m u:1000:rwx "$MODELS" "$CONFIG" "$LOGS"
fi

echo "✅ NFS permissions fixed for Open WebUI components."
EOF

echo ""
echo "Next steps:"
echo "1. Create PersistentVolumes/PVCs in Kubernetes pointing to NFS paths."
echo "2. Deploy Open WebUI Deployment mounting PVCs to /models, /config, /logs."
echo "3. Expose the service via NodePort to access the Web UI."

