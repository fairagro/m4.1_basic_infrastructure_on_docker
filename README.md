# m4.1_basic_infrastructure_on_docker

To rollout the M4.1 infrastructure on docker instead of kuberenets.
It's only a temporary quick&dirty project and the following steps are meant to be
performed directly on the target machine.

## Prerequisites

### Install requires packages

```bash
sudo dnf update && sudo dnf install -y \
    git \
    gpg \
    ca-certificates \
    curl \
    rsync
```

### Install age

```bash
VERSION=$(curl -s https://api.github.com/repos/FiloSottile/age/releases/latest | grep tag_name | cut -d '"' -f4)
curl -Lo /tmp/age.tar.gz "https://github.com/FiloSottile/age/releases/download/${VERSION}/age-${VERSION}-linux-amd64.tar.gz"
tar -xzf /tmp/age.tar.gz -C /tmp
sudo install /tmp/age/age /tmp/age/age-keygen /usr/local/bin/
rm -rf /tmp/age /tmp/age.tar.gz
```

### Install sops

```bash
VERSION=$(curl -Ls https://api.github.com/repos/mozilla/sops/releases/latest | grep tag_name | cut -d '"' -f4)
sudo curl -Lso /usr/local/bin/sops "https://github.com/mozilla/sops/releases/download/$VERSION/sops-$VERSION.linux.amd64"
sudo chmod +x /usr/local/bin/sops
```

### Install docker

on ubuntu/debian:

```bash
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update && sudo apt-get install \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-compose-plugin
```

on AlmaLinux/RedHat:

```bash
sudo dnf remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
newgrp docker
```

### Enable overcommit

This is a host setting that is needed by redis:

```bash
echo 'vm.overcommit_memory=1' | sudo tee /etc/sysctl.d/99-redis-overcommit.conf
sudo sysctl --system
```

### Checkout this repo

Besides checking out, we also need an empty file with special ownership that
will be mounted into the nextcloud container.

```bash
git clone https://github.com/fairagro/m4.1_basic_infrastructure_on_docker.git
sudo install -o 82 -g 82 -m 0644 /dev/null m4.1_basic_infrastructure_on_docker/nextcloud/redis-session.ini
```

## How to deploy

This is how to deploy:

* Set the age secret key to the private deployment key which can be
  found in keepass:

  ```bash
  mkdir -p ~/.config/sops/age
  vim ~/.config/sops/age/key.txt
  chmod 400 ~/.config/sops/age/key.txt
  ```

* run docker compose

  ```bash
  cd m4.1_basic_infrastructure_on_docker
  sops exec-env environments/productive/secrets.enc.yaml 'docker compose up -d'
  ```

## Remark on the file `docker-compose.yml`

* The service containers `nextcloud` and `nginx-proxy` are built using different
  UID (82 vs 101). So we run them with group id 1000, so they can share data.

## Remark on the file `nextcloud/redis-session.ini`

It will be mounted as -- initially -- empty file into the nextcloud container.
The nextcloud entrypoint will then write to it. We use this approach as otherwise
this file would not be writable by a non-root container. We do not wont to add the
contentets of this file to the git repo (it contains secrets), so it was added to
`.gitignore` after the initial creation.

## Restoring the backup

The backup consists of filesystem backups of the two kubernetes volumes called
`nextcloud` and `nextcloud_data` and a database backup.
There are several subdirectories in the `nextcloud` volume that were mounted to
the corresponding directories in `/var/www/html`. The `nextcloud_data` volume was
mounted to `/nextcloud_data`, while the nextcloud config pointed to that directory.

Our current docker installation just uses one volume, mounted to `/var/www/html`.

Note that we won't make use of the configuration files of the backup, as they differ
quite a lot from a freshly set up configuration. Instead the config will is imposed
by the docker compose file and we need to deal with some `instanceid`-related issues.

### Assumptions

These are our assumptions:

* The two volume backups are created on the kubernetes hosts using

  ```bash
  sudo rsync -a --numeric-ids --times --devices --specials --perms --acls --xattrs ...
  ```

  So we have a filesystem-level backup, preserving all the original ownerships, permission
  and the like. Thus we need root/sudo permission to deal with this backup.
  If you want to archive the backup, use:

  ```bash
  sudo tar czf backup.tar.bz2 --numeric-owner --preserve-permissions --acls --xattrs backup_folder
  sudo tar xzf backup.tar.bz2 --same-owner --same-permissions --acls --xattrs
  ```

* The database backup is to be created using `pg_dumpall`.

### Preparation

First we assume these backup locations:

* `NEXTCLOUD_BACKUP=<path to the backup of the nextcloud volume>`
* `NEXTCLOUD_DATA_BACKUP=<path to the backup of the nextcloud data volume>`
* `DB_BACKUP=<path to the pg_dumpall file>`
* `NEXTCLOUD_HOST_PATH=/var/lib/docker/volumes/m41_basic_infrastructure_on_docker_nextcloud/_data`
* `NEXTCLOUD_DATA_HOST_PATH=/var/lib/docker/volumes/m41_basic_infrastructure_on_docker_nextcloud_data/_data`

Figure out the old `instanceid` and `dbpassword`:

```bash
OLD_INSTANCEID=$(sudo grep instanceid $NEXTCLOUD_BACKUP/config/config.php | cut -d "'" -f 4)
sudo grep dbpassword $NEXTCLOUD_BACKUP/config/config.php | cut -d "'" -f 4
```

The `dbpassword` needs to be written to `environment/productive/secrets.enc.yaml`.

### Restore process

```bash
sops exec-env environments/prod/secrets.enc.yaml 'docker compose --env-file environments/prod/values.env up -d'
docker exec -it m41_basic_infrastructure_on_docker-nextcloud-1 /var/www/html/occ maintenance:mode --on
```

Wait until maintenance mod is active...

```bash
NEW_INSTANCEID=$(docker exec -it m41_basic_infrastructure_on_docker-nextcloud-1 grep instanceid config/config.php | cut -d "'" -f 4)
TEMP=$(mktemp -d)
# Delete the content of the old /var/www/html folder, without the config folder.
# We want to replace all files from the backup, except the config because it's not up-to-date anymore.
sudo find "$NEXTCLOUD_HOST_PATH" -mindepth 1 -path "$NEXTCLOUD_HOST_PATH/config" -prune -o -exec rm -rf {} +
# Restore the contents of /var/www/html from the backup, except the config folder
sudo rsync -a --numeric-ids --times --devices --specials --perms --acls --xattrs $NEXTCLOUD_BACKUP/html/* $NEXTCLOUD_HOST_PATH
sudo rsync -a --numeric-ids --times --devices --specials --perms --acls --xattrs $NEXTCLOUD_BACKUP/custom_apps /$NEXTCLOUD_HOST_PATH
sudo rsync -a --numeric-ids --times --devices --specials --perms --acls --xattrs $NEXTCLOUD_BACKUP/root $NEXTCLOUD_HOST_PATH
sudo rsync -a --numeric-ids --times --devices --specials --perms --acls --xattrs $NEXTCLOUD_BACKUP/themes $NEXTCLOUD_HOST_PATH
# Delete the content of the old /var/www/data folder.
[ -n "$NEXTCLOUD_DATA_HOST_PATH" ] && sudo sh -c "rm -rf $NEXTCLOUD_DATA_HOST_PATH/*"
# Restore the contens of /var/www/data from the backup
sudo rsync -a --numeric-ids --times --devices --specials --perms --acls --xattrs $NEXTCLOUD_DATA_BACKUP/data/* $NEXTCLOUD_DATA_HOST_PATH
# Take the active appdata folder of the backup and rename it to the name of the appdata folder of our current nextcloud instance,
# while deleting all other appdata folders.
sudo mv $NEXTCLOUD_DATA_HOST_PATH/appdata_$OLD_INSTANCEID $TEMP/appdata_$NEW_INSTANCEID
[ -n "$NEXTCLOUD_DATA_HOST_PATH" ] && sudo sh -c "rm -rf $NEXTCLOUD_DATA_HOST_PATH/appdata_*"
sudo mv $TEMP/appdata_$NEW_INSTANCEID $NEXTCLOUD_DATA_HOST_PATH/
[ -n "$TEMP" ] && sudo rm -rf "$TEMP"
docker exec -i m41_basic_infrastructure_on_docker-db-1 su - postgres -c 'psql -c "DROP DATABASE \"nextcloud\""'
cat $DB_BACKUP | docker exec -i m41_basic_infrastructure_on_docker-db-1 su - postgres -c 'psql'
docker exec -it m41_basic_infrastructure_on_docker-nextcloud-1 /var/www/html/occ maintenance:mode --off
```

Note that it is normal if the database restore shows errors due to missing tables and schemas and the like.
This is because the kuberentes postgresql operator uses a bunch of postgresql extensions that are not
available on a plain postgresql docker images.
