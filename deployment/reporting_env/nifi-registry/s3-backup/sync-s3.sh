#!/bin/sh

# Immediately exit if any of the command return codes is anything other than a 0
set -e

# Download the remote files first
aws s3 cp --no-progress --recursive $S3_BACKUP_URI $BACKUP_DIRECTORY

# Change the files owner
chown -R 1000:1000 $BACKUP_DIRECTORY

# Create cron entry
echo "$BACKUP_CRON_SCHEDULE aws s3 sync --no-progress $BACKUP_DIRECTORY $S3_BACKUP_URI" > /etc/crontabs/root

# Start the cron job in foreground
crond -f
