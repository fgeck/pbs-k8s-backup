#!/bin/bash

# Required Env Vars
required_vars=("BACKUP_NAME" "POSTGRES_HOST" "POSTGRES_USER" "POSTGRES_PASSWORD" "PROXMOX_BACKUP_SERVER_NAMESPACE" "PROXMOX_BACKUP_SERVER_PASSWORD" "PROXMOX_BACKUP_SERVER_FINGERPRINT" "PROXMOX_BACKUP_SERVER_REPOSITORY" "TELEGRAM_BOT_TOKEN" "TELEGRAM_CHAT_ID")

# Flag to track if all variables are set
all_set=true
# Check each variable
for var in "${required_vars[@]}"; do
    if [[ -z "${!var}" ]]; then
        echo "Error: Environment variable $var is not set."
        all_set=false
    fi
done
# Exit if any variable is not set
if [[ "$all_set" == false ]]; then
    echo "Please set the required environment variables and try again."
    exit 1
fi

send_telegram_message() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        -d chat_id="$TELEGRAM_CHAT_ID" \
        -d text="$message"
}

# Function to clean up backup files
cleanup() {
    echo "Cleaning up backup files..."
    rm -f "$BACKUP_FILE"
}

# Set up trap to call cleanup function on script exit
trap cleanup EXIT

LOG_FILE=/var/log/backup.log
BACKUP_DIRECTORY="/backup"
BACKUP_FILE="/backup/postgres-backup.sql"
echo "Starting Postgres backup to file"
PGPASSWORD="$PGPASSWORD" pg_dumpall -h "$PGHOST" -U "$PGUSER" > "$BACKUP_FILE"
echo "Postgres successfully backupped to file: $(du -h "$BACKUP_FILE" | cut -f1)"

export PBS_FINGERPRINT=$PROXMOX_BACKUP_SERVER_FINGERPRINT
export PBS_PASSWORD=$PROXMOX_BACKUP_SERVER_PASSWORD 
proxmox-backup-client backup "$BACKUP_NAME:$BACKUP_DIRECTORY" --repository "$PROXMOX_BACKUP_SERVER_REPOSITORY" --backup-id $BACKUP_NAME --ns $PROXMOX_BACKUP_SERVER_NAMESPACE
if [[ $? -ne 0 ]]; then
    ERROR_MSG="$(date '+%Y-%m-%d %H:%M:%S') - Backup failed for $BACKUP_FILE"
    send_telegram_message "$ERROR_MSG"
    echo "$ERROR_MSG"
    exit 1
else
    SUCCESS_MSG="$(date '+%Y-%m-%d %H:%M:%S') - Backup for $BACKUP_FILE completed successfully."
    echo "$SUCCESS_MSG"
    # send_telegram_message "$SUCCESS_MSG"
fi
