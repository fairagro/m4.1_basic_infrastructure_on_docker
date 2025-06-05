#!/usr/bin/env sh

# install OnlyOffice integration (using richdocuments and enabling WOPI for OnlyOffice would also be possible)
php /var/www/html/occ app:install onlyoffice

# Configure OnlyOffice integration app
{{- $onlyoffice_server := (first (index .Values "fairagro-onlyoffice").ingress.hosts).host }}
{{- $nextcloud_server := .Values.nextcloud.nextcloud.host }}
{{- $jwt_secret := (index .Values "fairagro-onlyoffice").jwt_secret }}
php /var/www/html/occ config:app:set onlyoffice DocumentServerUrl --value=https://{{ $onlyoffice_server }}/
# For some reason we also we to set the (internal) StorageURL which is the nextcloud URL.
php /var/www/html/occ config:app:set onlyoffice StorageUrl --value=https://{{ $nextcloud_server }}/
php /var/www/html/occ config:app:set onlyoffice jwt_secret --value={{ $jwt_secret }}
# Enable manual save
php /var/www/html/occ config:app:set onlyoffice customizationForcesave --value=true

# Install additional apps
# needed to forbid WebDAV access with Windows Explorer -- additional manual settings are required
php /var/www/html/occ app:install files_accesscontrol
php /var/www/html/occ app:install calendar
php /var/www/html/occ app:install deck
php /var/www/html/occ app:install announcementcenter

# Disable unwanted apps
php /var/www/html/occ app:disable admin_audit
php /var/www/html/occ app:disable bruteforcesettings
php /var/www/html/occ app:disable encryption
php /var/www/html/occ app:disable files_external
php /var/www/html/occ app:disable firstrunwizard
php /var/www/html/occ app:disable support
php /var/www/html/occ app:disable survey_client
php /var/www/html/occ app:disable suspicious_login
php /var/www/html/occ app:disable twofactor_totp
php /var/www/html/occ app:disable user_ldap
php /var/www/html/occ app:disable user_status
php /var/www/html/occ app:disable weather_status

# add missing database indices
php /var/www/html/occ db:add-missing-indices