set -e

# set up logrotation
cp ops/lib/cron_logrotate.sh /etc/cron.daily/app
chmod +x /etc/cron.daily/app
