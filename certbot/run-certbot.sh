#!/usr/bin/env sh

set -eu
umask 027

echo "dns_cloudflare_api_token = $CLOUDFLARE_API_TOKEN" > /tmp/cloudflare.ini
chmod 600 /tmp/cloudflare.ini

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
  -d "$CERTBOT_DOMAINS"

ls -l /etc/letsencrypt/live/
