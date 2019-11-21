#!/bin/sh

/usr/sbin/logrotate /app/ops/config/logrotate.conf
exit_value=$?
if [ $exit_value != 0 ]
then
    /usr/bin/logger -t logrotate "ALERT exited abnormally with [$EXITVALUE]"
fi
exit 0
