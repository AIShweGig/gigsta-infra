#!/usr/bin/env bash
# Backup Gigsta's SQLite database + uploaded files.
#
# Usage:
#   scripts/backup.sh                          # writes to ./backups/
#   BACKUP_DIR=/mnt/backups scripts/backup.sh  # custom location
#
# Add to crontab on the server:
#   0 3 * * * /opt/gigsta/scripts/backup.sh >> /var/log/gigsta-backup.log 2>&1

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BACKUP_DIR="${BACKUP_DIR:-$PROJECT_DIR/backups}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
KEEP_DAYS="${BACKUP_KEEP_DAYS:-14}"

mkdir -p "$BACKUP_DIR"

# Find the backend container
CONTAINER="$(docker ps --filter 'name=backend' --format '{{.Names}}' | head -1)"
if [[ -z "$CONTAINER" ]]; then
  echo "ERROR: no running backend container found" >&2
  exit 1
fi

echo "» Snapshotting database from container '$CONTAINER'..."

# Use sqlite3 .backup which works even if the DB is in use
docker exec "$CONTAINER" sh -c 'apt-get -qq install -y sqlite3 > /dev/null 2>&1 || true; sqlite3 /data/gigsta.db ".backup /data/snapshot.db"' || {
  # Fallback: just copy the file (less safe but works without sqlite3 installed)
  echo "  (sqlite3 unavailable, falling back to file copy)"
  docker exec "$CONTAINER" cp /data/gigsta.db /data/snapshot.db
}

docker cp "$CONTAINER:/data/snapshot.db" "$BACKUP_DIR/gigsta-$TIMESTAMP.db"
docker exec "$CONTAINER" rm -f /data/snapshot.db

# Also snapshot uploads if they exist
if docker exec "$CONTAINER" sh -c '[ -d /srv/uploads ]' 2>/dev/null; then
  echo "» Snapshotting uploads..."
  docker exec "$CONTAINER" tar czf - -C /srv uploads > "$BACKUP_DIR/uploads-$TIMESTAMP.tar.gz"
fi

# Rotate old backups
find "$BACKUP_DIR" -name "gigsta-*.db" -mtime "+$KEEP_DAYS" -delete 2>/dev/null || true
find "$BACKUP_DIR" -name "uploads-*.tar.gz" -mtime "+$KEEP_DAYS" -delete 2>/dev/null || true

echo "✓ Backup complete: $BACKUP_DIR/gigsta-$TIMESTAMP.db"
ls -lh "$BACKUP_DIR" | tail -10
