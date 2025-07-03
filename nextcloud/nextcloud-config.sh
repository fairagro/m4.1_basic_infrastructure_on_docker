#!/usr/bin/env sh

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
    'loglevel' => 1, // INFO
];
EOF

# *** Nextcloud miscellaneous configuration ***
cat > /var/www/html/config/misc.config.php <<EOF
<?php
\$CONFIG = [
    'default_phone_region' => 'DE',
    'enable_previews' => false,
    'check_data_directory_permissions' => false,
    'versions_retention_obligation' => '14, auto',
];
EOF