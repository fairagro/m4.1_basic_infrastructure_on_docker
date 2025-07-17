#!/bin/sh
set -e

NEXTCLOUD_CONTAINER=nextcloud
POSTGRES_CONTAINER=db

BACKUP_DIR=/backup

echo "Stoppe Nextcloud und Postgres Container..."
docker-compose stop nextcloud db

echo "Aktiviere Nextcloud Wartungsmodus..."
docker exec -u www-data $NEXTCLOUD_CONTAINER php occ maintenance:mode --on || true

echo "Warte bis Wartungsmodus aktiv ist..."
while true; do
  MAINTENANCE=$(docker exec -u www-data $NEXTCLOUD_CONTAINER php occ maintenance:mode || echo "not running")
  if echo "$MAINTENANCE" | grep -q "enabled"; then
    break
  fi
  echo "Noch nicht aktiv, warte 2 Sekunden..."
  sleep 2
done

echo "Restore Nextcloud Volumes..."
# Achtung: Container müssen gestoppt sein für das Volume Restore.
tar -xpf "$BACKUP_DIR/nextcloud.tar" -C /var/lib/docker/volumes/nextcloud/_data
tar -xpf "$BACKUP_DIR/nextcloud_data.tar" -C /var/lib/docker/volumes/nextcloud_data/_data

echo "Restore Datenbank Backup..."
docker-compose start db
sleep 5 # Warte auf Postgres Startup
docker exec -i $POSTGRES_CONTAINER pg_restore --clean --if-exists --no-owner -U "$NEXTCLOUD_DB_USER" -d nextcloud < "$BACKUP_DIR/nextcloud-db.dump"

echo "Starte Nextcloud Container..."
docker-compose start nextcloud

echo "Deaktiviere Nextcloud Wartungsmodus..."
docker exec -u www-data $NEXTCLOUD_CONTAINER php occ maintenance:mode --off

echo "Restore abgeschlossen."
