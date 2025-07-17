#!/bin/sh
set -e

NEXTCLOUD_CONTAINER=nextcloud
POSTGRES_CONTAINER=db
BACKUP_DIR=/backups
TIMESTAMP=$(date +%Y%m%d%H%M%S)

mkdir -p "$BACKUP_DIR"

echo "1. Maintenance Mode aktivieren"
docker exec "$NEXTCLOUD_CONTAINER" php occ maintenance:mode --on

echo "2. Warten auf aktivierten Maintenance Mode..."
while ! docker exec "$NEXTCLOUD_CONTAINER" php occ maintenance:mode | grep -q "enabled"; do
  sleep 1
done

echo "3. Datenbank Backup (Postgres) durchführen"
docker exec "$POSTGRES_CONTAINER" pg_dump -U nextcloud nextcloud > "$BACKUP_DIR/nextcloud_db_${TIMESTAMP}.sql"

echo "4. Nextcloud Volumes sichern"
docker exec "$NEXTCLOUD_CONTAINER" tar czf /tmp/nextcloud_html_${TIMESTAMP}.tar.gz -C /var/www/html .
docker cp "$NEXTCLOUD_CONTAINER":/tmp/nextcloud_html_${TIMESTAMP}.tar.gz "$BACKUP_DIR/"

echo "5. Maintenance Mode deaktivieren"
docker exec "$NEXTCLOUD_CONTAINER" php occ maintenance:mode --off

echo "Backup abgeschlossen!"
