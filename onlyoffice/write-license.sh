#! /usr/bin/env sh

set -eu

LICENSE_PATH="/var/www/onlyoffice/Data/license.lic"

echo "$ONLYOFFICE_LICENSE" > "$LICENSE_PATH"
chmod 400 "$LICENSE_PATH"
# Set ownership to 'ds' user (OnlyOffice runs as this user internally)
chown ds:ds "$LICENSE_PATH" || echo "⚠️  chown failed, skipping"
echo "✅ License written to $LICENSE_PATH"