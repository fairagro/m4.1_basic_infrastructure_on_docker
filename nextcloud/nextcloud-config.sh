#!/usr/bin/env sh

# *** Nextcloud proxy configuration ***
# We cannot mount additional config files into /var/www/html/config/
# because this is a mounted directory itself. docker compose cannot
# relyably deal with this. So we write the config file here.
cat > /var/www/html/config/proxy.config.php <<EOF
<?php
\$CONFIG = [
    'trusted_proxies' => [
        0 => 'nginx-proxy',
    ],
    'forwarded_for_headers' => ['HTTP_X_FORWARDED_FOR'],
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
