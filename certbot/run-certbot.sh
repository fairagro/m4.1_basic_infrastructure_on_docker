#!/usr/bin/env sh

set -eu
umask 027

echo "dns_cloudflare_api_token = $CLOUDFLARE_API_TOKEN" > /tmp/cloudflare.ini
chmod 600 /tmp/cloudflare.ini

NEXTCLOUD_DOMAINS=$NEXTCLOUD_FQDN
ONLYOFFICE_DOMAINS=$ONLYOFFICE_FQDN

while :; do
    echo '🔄 Running certbot every 12h...'

    certbot certonly \
      --cert-name $NEXTCLOUD_FQDN \
      --dns-cloudflare \
      --dns-cloudflare-credentials /tmp/cloudflare.ini \
      --dns-cloudflare-propagation-seconds 60 \
      --non-interactive \
      --agree-tos \
      --email "$CERTBOT_EMAIL" \
      --logs-dir /var/log/letsencrypt \
      --config-dir /etc/letsencrypt \
      --work-dir /var/lib/letsencrypt \
      -v \
      -d "$NEXTCLOUD_DOMAINS"
    echo '✅ Cert requet/renewal for nextcloud complete...'

    certbot certonly \
      --cert-name $ONLYOFFICE_FQDN \
      --dns-cloudflare \
      --dns-cloudflare-credentials /tmp/cloudflare.ini \
      --dns-cloudflare-propagation-seconds 60 \
      --non-interactive \
      --agree-tos \
      --email "$CERTBOT_EMAIL" \
      --logs-dir /var/log/letsencrypt \
      --config-dir /etc/letsencrypt \
      --work-dir /var/lib/letsencrypt \
      -v \
      -d "$ONLYOFFICE_DOMAINS"
    chgrp -R 1000 "/etc/letsencrypt/live/${ONLYOFFICE_FQDN}"
    chmod -R g+r "/etc/letsencrypt/live/${ONLYOFFICE_FQDN}"
    echo '✅ Cert requet/renewal for onlyoffice complete...'

    sleep 43200
done
