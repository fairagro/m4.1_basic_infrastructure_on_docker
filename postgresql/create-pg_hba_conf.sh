#!/usr/bin/env sh

set -eu

# We need to write the pg_hba.conf dynamically as otherwise the entrypoint script
# sees a non-empty data folder and refuses to initialize the db.

OUTPUT_FILE="/var/lib/postgresql/data/pg_hba.conf"

cat > "$OUTPUT_FILE" <<EOF
# TYPE       DATABASE        USER            ADDRESS            METHOD

# Lokale Verbindungen über Unix-Domain-Sockets (nicht relevant in Docker)
local        all             all                                peer

# Nur nextcloud Verbindungen erlauben
hostnossl    nextcloud       nextcloud       172.31.255.0/28    scram-sha-256
hostnossl    nextcloud       nextcloud       172.31.255.0/28    scram-sha-256
hostnossl    onlyoffice      onlyoffice      172.31.254.0/28    scram-sha-256

# Optional: Allow localhost (e.g. for manual `psql` inside container)
hostnossl    all             all             127.0.0.1/32       scram-sha-256
hostnossl    all             all             ::1/128            scram-sha-256
EOF
