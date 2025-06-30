#!/usr/bin/env sh

# *** Nextcloud proxy configuration ***
# We cannot mount additional config files into /var/www/html/config/
# because this is a mounted directory itself. docker compose cannot
# relyably deal with this. So we write the config file here.
PROXY_IP=$(getent hosts nginx-proxy | awk '{ print $1 }')
cat > /var/www/html/config/reverse-proxy.config.php <<EOF
<?php
\$overwriteHost = getenv('OVERWRITEHOST');
if (\$overwriteHost) {
  \$CONFIG['overwritehost'] = \$overwriteHost;
}

\$overwriteProtocol = getenv('OVERWRITEPROTOCOL');
if (\$overwriteProtocol) {
  \$CONFIG['overwriteprotocol'] = \$overwriteProtocol;
}

\$overwriteCliUrl = getenv('OVERWRITECLIURL');
if (\$overwriteCliUrl) {
  \$CONFIG['overwrite.cli.url'] = \$overwriteCliUrl;
}

\$overwriteWebRoot = getenv('OVERWRITEWEBROOT');
if (\$overwriteWebRoot) {
  \$CONFIG['overwritewebroot'] = \$overwriteWebRoot;
}

\$overwriteCondAddr = getenv('OVERWRITECONDADDR');
if (\$overwriteCondAddr) {
  \$CONFIG['overwritecondaddr'] = \$overwriteCondAddr;
}

\$CONFIG['trusted_proxies'] = [
    '${PROXY_IP}',
];
\$trustedProxies = getenv('TRUSTED_PROXIES');
if (\$trustedProxies) {
  \$CONFIG['trusted_proxies'] = array_merge(
    \$CONFIG['trusted_proxies'],
    array_filter(array_map('trim', explode(' ', \$trustedProxies)))
  );
}

\$CONFIG['forwarded_for_headers'] = [
    'HTTP_X_FORWARDED_FOR',
];
EOF

# *** Nextcloud redis configuration ***
# This config is meant to use redis via unix domain sockets. Nevertheless
# you have to specify the socket file in terms of the env var REDIS_HOST.
cat > /var/www/html/config/redis.config.php <<EOF
<?php
\$CONFIG = [
    'memcache.distributed' => '\\OC\\Memcache\\Redis',
    'memcache.locking' => '\\OC\\Memcache\\Redis',
    'redis' => [
        'host' => getenv('REDIS_HOST'),
        'port' => 0,
        'timeout' => 0.0,
        'password' => (string) getenv('REDIS_HOST_PASSWORD'),
    ],
];
EOF

# *** Nextcloud cron configuration ***
cat > /var/www/html/config/cron.config.php <<EOF
<?php
\$CONFIG = [
    'maintenance_window_start' => 1,     // run background jobs at 1am
];
EOF

# *** Nextcloud logging configuration ***
cat > /var/www/html/config/logging.config.php <<EOF
<?php
\$CONFIG = [
    'log_type' => 'file',
    'logfile' => 'php://stdout',
    'loglevel' => 1, // DEBUG für maximalen Output
];
EOF

# *** Nextcloud miscellaneous configuration ***
cat > /var/www/html/config/misc.config.php <<EOF
<?php
\$CONFIG = [
    'default_phone_region' => 'DE',
    'check_data_directory_permissions' => false,
    'versions_retention_obligation' => '14, auto',
];
EOF