#!/usr/bin/env sh

set -eu

# We need to write the pg_hba.conf dynamically as otherwise the entrypoint script
# sees a non-empty data folder and refuses to initialize the db.

OUTPUT_FILE="/var/lib/postgresql/data/pg_hba.conf"

cat > "$OUTPUT_FILE" <<EOF
# TYPE       DATABASE        USER            ADDRESS            METHOD

# Allow passwordless local connections (for manual `psql` inside container)
local        all             postgres                           peer

# Allow nextcloud connections via unix domain sockets
local        nextcloud       nextcloud                          scram-sha-256
# The nextcloud initialization also requires access to the postgres database
local        postgres        nextcloud                          scram-sha-256

# Allow onlyoffice connections from dedicated network (unix domain sockets do
# not work fpr onlyoffice)
hostnossl    onlyoffice      onlyoffice      172.31.254.0/28    scram-sha-256
EOF
