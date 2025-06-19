#! /usr/bin/env sh

set -eu

echo "Writing license file..."
LICENSE_FILE="/var/www/onlyoffice/Data/license.lic"
if [ -n "$ONLYOFFICE_LICENSE" ]; then
    echo "$ONLYOFFICE_LICENSE" > "$LICENSE_FILE";
    chown ds:ds "$LICENSE_FILE";
    chmod 400 "$LICENSE_FILE";
fi;

exec /app/ds/run-document-server.sh "$@"