# Upgrade note to Nextcloud version 28.0.14

## Apps missing compatible version

As hinted by the Nextcloud System Overvoew page, these appa won't be supported
any more by Nextclou 28.0.14:

* Markdown Editor
* Plain text editor

## Upgrade procedure

The upgrade procedure depicted on the nextcloud web page do not work for our
setup. First on the System Overview page according to the docs we would expect
the button `Open updater`, instead we only have the button `Download now` which
will download a manual upgrade package, web based upgrading is not possible.
Second the documented manual upgrade procedure does not fit our docker setup,
so we have to modify it according to the following steps.

Please keep in mind that the upgrade path is always: upgrade to the newest
minor release/patch level of your cuurent nextcloud major version. In the next
step upgrade to the next major release. Repeat that until you've reached the
neest major release. Do not skip major releases!

1. Create a backup of the running nextcloud instance
2. Update the nextcloud image references in the `docker-compose.yml` file to
   `sha256:ce2e611181157e83cc9b5602b1b4e6603f892f8c1c15e938e1363d6639025de6`
   (which corresponds to `28.0.14-fpm-alpine`).
3. Restart docker compose:

   ```bash
   sops exec-env environments/prod/secrets.enc.yaml 'docker compose --env-file environments/prod/values.env down'
   sops exec-env environments/prod/secrets.enc.yaml 'docker compose --env-file environments/prod/values.env up -d'
   ```

4. Enter the nextcloud command line and issue an upgrade:

   ```bash
   docker exec -it m41_basic_infrastructure_on_docker-nextcloud-1 sh
   ./occ upgrade
   ./occ maintenance:repair --include-expensive
   ```

   Note that in this case the upgrade command does not seem to have any effect.

5. Open the Nextcloud Settings Overview web page. In this case we're observing
   a 'integrity check' failure, caused by the app `files_markdown` (we've been
   warned that the markdown app won't be available after the upgrade). So all
   we can currently do is deactivating the app:

   ```bash
   php occ app:disable files_markdown
   ```

   Now return to the Settings Overview page an press the `Rescan` button in
   the error message (it's currently unclear how to perform this from the
   command line).
