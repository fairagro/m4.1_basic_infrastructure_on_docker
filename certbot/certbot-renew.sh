#!/usr/bin/env sh

set -eu
umask 027

echo "dns_cloudflare_api_token = $CLOUDFLARE_API_TOKEN" > /tmp/cloudflare.ini
chmod 600 /tmp/cloudflare.ini

while :; do
    echo '🔄 Running certbot renew in 12h...'
    sleep 43200
    certbot renew \
        --dns-cloudflare \
        --dns-cloudflare-credentials /cloudflare.ini \
        --non-interactive \
        --quiet
    echo '✅ Renewal check complete...'
done