###  VM standup notes

Gitlab ticket : https://github.com/fairagro/basic_infrastructure/issues/148

Clone/Copy this repo to the VM. 
Create a file '.env'
set the POSTGRES_PASSWORD and DB_PASSWORD to the same value!
CLOUDFLARE_API_TOKEN should be set as well
You can get all of these from fairagro_keepass

docker compose up -d
docker compose down

# Unsure if the below is needed
Modify files/config.php and fill in the password entry

### Ansible notes
cd m4.1_basic_infrastructure_on_docker/ansible
< setup your venv >
ansible-playbook -i hosts.yaml limesurvey.yaml -u ansible --private-key <key_location> --list-tasks # sanity check
ansible-playbook -i hosts.yaml limesurvey.yaml -u ansible --private-key <key_location> --list-hosts # sanity check
ansible-playbook -i hosts.yaml limesurvey.yaml -u ansible --private-key <key_location> --check --diff  # sanity check, output not 100% matches real run
ansible-playbook -i hosts.yaml limesurvey.yaml -u ansible # run it for real

The vault.yml file was something I setup when investigating a different ansible-limesurvey implementation, and probably should be removed

### Cloudflare notes (for Letsencrypt)

Create an API token with the following particulars:
. must be dns:edit
. must include the fairagro.net domain

### DB notes

# When importing the normal SQL dump "02-limesurvey.sql", it failed as it seems 
# to require additional role information, which is only available via pg_dumpall "01-globals.sql"
# So that's why there are 2 SQL dumps
# When importing the DB, you import 01-globals, then 02-limesurvey
# I would have liked to do more testing to verify what exactly is happening here, but it seems to just work (tm), so ..
# You are expected to obtain these backups from S3 and put the SQL files in the locations required by the docker compose

postgres@fairagro-postgresql-limesurvey-0:~/pgdata/pgroot$ pg_dumpall --globals-only > 01-globals.sql
postgres@fairagro-postgresql-limesurvey-0:~/pgdata/pgroot$ pg_dump -F p -f 02-limesurvey.sql

# build a modified postgres 16.3 docker image with a couple of added extensions that were likely installed in the k8s postgres operator
# See db-custom/Dockerfile for further details
docker build -t custom-postgres:16-3-with-extensions db-custom/
docker compose down;docker volume rm limesurvey_db_data; docker compose up -d
docker exec -ti limesurvey_db bash
psql -U limesurvey -d postgres -c 'drop database limesurvey;'
psql -U limesurvey -d postgres -c 'create database limesurvey;'
psql -U limesurvey -d limesurvey -f /01-globals.sql
psql -U limesurvey -d limesurvey -f /02-limesurvey.sql

### Final sanity checks

browse to 
https://<IP>/index.php/admin/authentication/sa/login
Check everything looks sane

When the DNS cut is active, survey.fairagro.net should resolve and browse correctly (LE certs correct).

### Git repo notes

I had no time to fully get sops/age working.
Rudimentary secrets-checking before committing to repo is:

# cd to the root of this repo, then pull and run the gitleaks checker
docker pull zricethezav/gitleaks:latest
docker run -v .:/path zricethezav/gitleaks:latest --verbose dir ./path/limesurvey/ --log-level=trace
docker run -v .:/path zricethezav/gitleaks:latest --verbose dir ./path/ --log-level=trace

# Sample gitleaks output looks like:
..
1:06PM TRC scanning path path=path/postgresql/create-dbs.sh
1:06PM TRC scanning path path=path/postgresql/create-pg_hba_conf.sh
1:06PM INF scanned ~86594 bytes (86.59 KB) in 82.6ms
1:06PM INF no leaks found

### Migrate back to k8s notes

The below SQL statements might be required, it's unclear exactly what these are for ..
Possibly these are just normal additional stuff from the k8s postgres operator ?

--
-- Role memberships
--

GRANT cron_admin TO postgres WITH ADMIN OPTION;
GRANT cron_admin TO admin WITH INHERIT TRUE GRANTED BY postgres;
GRANT limesurvey TO admin WITH ADMIN OPTION, INHERIT TRUE GRANTED BY postgres;
GRANT limesurvey_owner TO admin WITH ADMIN OPTION, INHERIT TRUE GRANTED BY postgres;
GRANT limesurvey_public_owner TO limesurvey_owner WITH ADMIN OPTION, INHERIT TRUE GRANTED BY postgres;
GRANT limesurvey_public_reader TO limesurvey_public_owner WITH ADMIN OPTION, INHERIT TRUE GRANTED BY postgres;
GRANT limesurvey_public_reader TO limesurvey_public_writer WITH INHERIT TRUE GRANTED BY postgres;
GRANT limesurvey_public_writer TO limesurvey_public_owner WITH ADMIN OPTION, INHERIT TRUE GRANTED BY postgres;
GRANT limesurvey_reader TO limesurvey_owner WITH ADMIN OPTION, INHERIT TRUE GRANTED BY postgres;
GRANT limesurvey_reader TO limesurvey_writer WITH INHERIT TRUE GRANTED BY postgres;
GRANT limesurvey_writer TO limesurvey_owner WITH ADMIN OPTION, INHERIT TRUE GRANTED BY postgres;
