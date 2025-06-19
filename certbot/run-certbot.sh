#!/usr/bin/env sh

set -eu
umask 027

echo "dns_cloudflare_api_token = $CLOUDFLARE_API_TOKEN" > /tmp/cloudflare.ini
chmod 600 /tmp/cloudflare.ini

while :; do
    echo '🔄 Running certbot every 12h...'

    certbot certonly \
      --cert-name nextcloud2.fairagro.net \
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
      --cert-name onlyoffice2.fairagro.net \
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
      echo '✅ Cert requet/renewal for onlyoffice complete...'

      sleep 43200
done
