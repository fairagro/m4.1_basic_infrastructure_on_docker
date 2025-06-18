#!/bin/sh

# create-dbs.sh - Initializes databases for Nextcloud and OnlyOffice

# Exit immediately if a command exits with a non-zero status
set -e

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
CREATE DATABASE "$NEXTCLOUD_DB";
CREATE USER "$NEXTCLOUD_DB_USER" WITH PASSWORD '$NEXTCLOUD_DB_PASSWORD';
GRANT ALL PRIVILEGES ON DATABASE "$NEXTCLOUD_DB" TO "$NEXTCLOUD_DB_USER";
-- Connect to the new database to set schema privileges
\c "$NEXTCLOUD_DB"
GRANT ALL ON SCHEMA public TO "$NEXTCLOUD_DB_USER";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO "$NEXTCLOUD_DB_USER";

-- Create OnlyOffice database and user
CREATE DATABASE "$ONLYOFFICE_DB";
CREATE USER "$ONLYOFFICE_DB_USER" WITH PASSWORD '$ONLYOFFICE_DB_PASSWORD';
GRANT ALL PRIVILEGES ON DATABASE "$ONLYOFFICE_DB" TO "$ONLYOFFICE_DB_USER";
EOF
