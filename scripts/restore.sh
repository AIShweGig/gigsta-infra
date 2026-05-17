#!/usr/bin/env bash
# Restore a Gigsta backup. THIS WILL OVERWRITE THE CURRENT DATABASE.
#
# Usage:
#   scripts/restore.sh ./backups/gigsta-20260515-030001.db
#   scripts/restore.sh ./backups/gigsta-20260515-030001.db ./backups/uploads-20260515-030001.tar.gz

set -euo pipefail

DB_BACKUP="${1:-}"
UPLOAD_BACKUP="${2:-}"

if [[ -z "$DB_BACKUP" || ! -f "$DB_BACKUP" ]]; then
  echo "Usage: $0 <db-backup.db> [uploads-backup.tar.gz]"
  exit 1
fi

CONTAINER="$(docker ps --filter 'name=backend' --format '{{.Names}}' | head -1)"
if [[ -z "$CONTAINER" ]]; then
  echo "ERROR: no running backend container found" >&2
  exit 1
fi

read -p "This will OVERWRITE the current database in '$CONTAINER'. Continue? [y/N] " yn
[[ "$yn" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }

echo "» Stopping the API to avoid corruption..."
docker exec "$CONTAINER" pkill -SIGTERM uvicorn || true
sleep 2

echo "» Copying database into container..."
docker cp "$DB_BACKUP" "$CONTAINER:/data/gigsta.db"

if [[ -n "$UPLOAD_BACKUP" && -f "$UPLOAD_BACKUP" ]]; then
  echo "» Restoring uploads..."
  docker exec "$CONTAINER" rm -rf /srv/uploads
  cat "$UPLOAD_BACKUP" | docker exec -i "$CONTAINER" tar xzf - -C /srv
fi

echo "» Restarting backend container..."
docker restart "$CONTAINER" > /dev/null

# Wait for it to be healthy again
for i in $(seq 1 30); do
  if docker exec "$CONTAINER" sh -c 'curl -fsS http://localhost:8000/api/health > /dev/null 2>&1'; then
    echo "✓ Restored. Backend healthy after ${i}s."
    exit 0
  fi
  sleep 1
done
echo "WARNING: backend did not come healthy in 30s. Check logs:" >&2
echo "  docker logs $CONTAINER" >&2
exit 1
