#!/usr/bin/env sh

# Zielpfad (kann angepasst werden)
HTPASSWD_PATH="/tmp/nextcloud_status_credentials.htpasswd"

# Prüfen, ob die Umgebungsvariable gesetzt ist
if [ -z "$NEXTCLOUD_FPM_STATUS_CREDENTIALS" ]; then
  echo "ERROR: NEXTCLOUD_FPM_STATUS_CREDENTIALS is not set." >&2
  exit 1
fi

# Inhalt sicher in die Datei schreiben
echo "$NEXTCLOUD_FPM_STATUS_CREDENTIALS" > "$HTPASSWD_PATH"
chmod 600 "$HTPASSWD_PATH"