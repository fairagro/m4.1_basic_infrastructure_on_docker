#!/usr/bin/env sh

# install OnlyOffice integration
php /var/www/html/occ app:install onlyoffice

# Configure OnlyOffice integration app
php /var/www/html/occ config:app:set onlyoffice DocumentServerUrl --value=https://${ONLYOFFICE_SERVER}/
php /var/www/html/occ config:app:set onlyoffice DocumentServerInternalUrl --value=https://${ONLYOFFICE_SERVER}:8443/
# For some reason we also we to set the (internal) StorageURL which is the nextcloud URL.
php /var/www/html/occ config:app:set onlyoffice StorageUrl --value=https://${NEXTCLOUD_TRUSTED_DOMAINS}/
php /var/www/html/occ config:app:set onlyoffice jwt_secret --quiet --value=${ONLYOFFICE_JWT_SECRET}
# Enable manual save
php /var/www/html/occ config:app:set onlyoffice customizationForcesave --value=true

# Install additional apps
php /var/www/html/occ app:install files_accesscontrol
php /var/www/html/occ app:install calendar
php /var/www/html/occ app:install deck
php /var/www/html/occ app:install announcementcenter

# Remove outdated app
php /var/www/html/occ app:remove files_markdown

# Enable wanted apps
php /var/www/html/occ app:enable bruteforcesettings

# Disable unwanted apps
php /var/www/html/occ app:disable admin_audit
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