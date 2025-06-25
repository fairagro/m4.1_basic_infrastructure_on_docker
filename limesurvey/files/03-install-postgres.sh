apt-get update
apt-get install -y wget gnupg lsb-release

# Add PostgreSQL APT repository
echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" \
	  > /etc/apt/sources.list.d/pgdg.list

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/postgresql.gpg

apt-get update
apt-get install -y postgresql-client-16
