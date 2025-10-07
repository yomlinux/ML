#!/bin/bash
set -e
echo "⚡ Setting up NFS Server Permissions for Kubeflow"

NFS_SERVER="10.0.0.134"
BASE="/data/app2/kubeflow"
SHARED="$BASE/shared"
DB="$BASE/mariadb"
MINIO="$BASE/minio"
CENTRALDASHBOARD="$BASE/centraldashboard"
ML_PIPELINE="$BASE/ml-pipeline"
METADATA_DB="$BASE/metadata-db"
METADATA_WRITER="$BASE/metadata-writer"
PROFILE_CONTROLLER="$BASE/profile-controller"
NOTEBOOKS_CONTROLLER="$BASE/notebooks-controller"

ssh root@$NFS_SERVER bash -s <<'EOF'
set -e

BASE="/data/app2/kubeflow"
SHARED="$BASE/shared"
DB="$BASE/mariadb"
MINIO="$BASE/minio"
CENTRALDASHBOARD="$BASE/centraldashboard"
ML_PIPELINE="$BASE/ml-pipeline"
METADATA_DB="$BASE/metadata-db"
METADATA_WRITER="$BASE/metadata-writer"
PROFILE_CONTROLLER="$BASE/profile-controller"
NOTEBOOKS_CONTROLLER="$BASE/notebooks-controller"

# Create directories
mkdir -p "$SHARED" "$DB" "$MINIO" "$CENTRALDASHBOARD" "$ML_PIPELINE" "$METADATA_DB" "$METADATA_WRITER" "$PROFILE_CONTROLLER" "$NOTEBOOKS_CONTROLLER"

# Set ownership and permissions
# MariaDB (UID/GID 999)
chown -R 999:999 "$DB"
chmod 750 "$DB"
chmod g+s "$DB"
chmod +t "$DB"

# MinIO (UID/GID 1000)
chown -R 1000:1000 "$MINIO"
chmod 750 "$MINIO"
chmod g+s "$MINIO"

# CentralDashboard, ML Pipeline, Metadata DB/Writer, Profile, Notebooks (UID/GID 1000)
for dir in "$CENTRALDASHBOARD" "$ML_PIPELINE" "$METADATA_DB" "$METADATA_WRITER" "$PROFILE_CONTROLLER" "$NOTEBOOKS_CONTROLLER" "$SHARED"; do
  chown -R 1000:1000 "$dir" || true
  chmod 770 "$dir"
  chmod g+s "$dir"
done

# Optional: set ACL if available
if command -v setfacl >/dev/null 2>&1; then
  setfacl -d -m u:999:rwx "$DB"
  setfacl -m u:999:rwx "$DB"
  setfacl -d -m u:1000:rwx "$MINIO" "$CENTRALDASHBOARD" "$ML_PIPELINE" "$METADATA_DB" "$METADATA_WRITER" "$PROFILE_CONTROLLER" "$NOTEBOOKS_CONTROLLER" "$SHARED"
  setfacl -m u:1000:rwx "$MINIO" "$CENTRALDASHBOARD" "$ML_PIPELINE" "$METADATA_DB" "$METADATA_WRITER" "$PROFILE_CONTROLLER" "$NOTEBOOKS_CONTROLLER" "$SHARED"
fi

echo "✅ NFS permissions fixed for all Kubeflow components."
EOF

echo ""
echo "Next steps:"
echo "1. Apply the full Kubeflow YAML: kubectl apply -f deployment.yaml"
echo "2. Verify pods are running: kubectl get pods -n kubeflow"
echo "3. Access Kubeflow UI via Istio NodePort: http://10.0.0.131:32080/centraldashboard"

