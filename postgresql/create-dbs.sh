#!/usr/bin/env sh

# create-dbs.sh - Initializes databases for Nextcloud and OnlyOffice

# Exit immediately if a command exits with a non-zero status
set -eu

# Check that all required environment variables are set
required_vars="POSTGRES_PASSWORD NEXTCLOUD_DB NEXTCLOUD_DB_USER NEXTCLOUD_DB_PASSWORD ONLYOFFICE_DB ONLYOFFICE_DB_USER ONLYOFFICE_DB_PASSWORD"

for var in $required_vars; do
  eval "value=\$$var"
  if [ -z "$value" ]; then
    echo "Error: Environment variable $var is not set." >&2
    exit 1
  fi
done

# Execute SQL commands using psql, assuming the script runs as the 'postgres' user
psql -v ON_ERROR_STOP=1 --username "postgres" <<EOF
-- Create Nextcloud database and user
CREATE DATABASE "$NEXTCLOUD_DB" TEMPLATE template0;
CREATE USER "$NEXTCLOUD_DB_USER" WITH PASSWORD '$NEXTCLOUD_DB_PASSWORD';
ALTER DATABASE "$NEXTCLOUD_DB" OWNER TO "$NEXTCLOUD_DB_USER";

-- Create OnlyOffice database and user
CREATE DATABASE "$ONLYOFFICE_DB" TEMPLATE template0;
CREATE USER "$ONLYOFFICE_DB_USER" WITH PASSWORD '$ONLYOFFICE_DB_PASSWORD';
ALTER DATABASE "$ONLYOFFICE_DB" OWNER TO "$ONLYOFFICE_DB_USER";
EOF
