#!/bin/bash

# Required Env Vars
required_vars=("BACKUP_NAME" "MONGODB_HOST" "MONGODB_USER" "MONGODB_PASSWORD" "PROXMOX_BACKUP_SERVER_NAMESPACE" "PROXMOX_BACKUP_SERVER_PASSWORD" "PROXMOX_BACKUP_SERVER_FINGERPRINT" "PROXMOX_BACKUP_SERVER_REPOSITORY")

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

send_notifications() {
    local title="$1"
    local message="$2"
    if [[ -n "${TELEGRAM_BOT_TOKEN}" ]] && [[ -n "${TELEGRAM_CHAT_ID}" ]]; then
        curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
            -d chat_id="${TELEGRAM_CHAT_ID}" \
            -d text="${message}" > /dev/null
    fi
    if [[ -n "${PUSHOVER_BACKUPS_TOKEN}" ]] && [[ -n "${PUSHOVER_USER_KEY}" ]]; then
        curl -s \
            --form-string "token=${PUSHOVER_BACKUPS_TOKEN}" \
            --form-string "user=${PUSHOVER_USER_KEY}" \
            --form-string "title=${title}" \
            --form-string "message=${message}" \
            --form-string "priority=1" \
            "https://api.pushover.net/1/messages.json" > /dev/null
    fi
}

# Function to clean up backup files
cleanup() {
    echo "Cleaning up backup files..."
    rm -rf "$BACKUP_DIRECTORY"
}

# Set up trap to call cleanup function on script exit
trap cleanup EXIT

BACKUP_DIRECTORY="/backup/mongodb-dump"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIRECTORY"

MONGODB_PORT="${MONGODB_PORT:-27017}"

echo "Starting MongoDB backup using mongodump"
mongodump \
    --host "$MONGODB_HOST" \
    --port "$MONGODB_PORT" \
    --username "$MONGODB_USER" \
    --password "$MONGODB_PASSWORD" \
    --authenticationDatabase admin \
    --oplog \
    --out "$BACKUP_DIRECTORY"
echo "MongoDB successfully dumped to directory: $(du -sh "$BACKUP_DIRECTORY" | cut -f1)"

export PBS_FINGERPRINT=$PROXMOX_BACKUP_SERVER_FINGERPRINT
export PBS_PASSWORD=$PROXMOX_BACKUP_SERVER_PASSWORD
proxmox-backup-client backup "$BACKUP_NAME.pxar:$BACKUP_DIRECTORY" --repository "$PROXMOX_BACKUP_SERVER_REPOSITORY" --backup-id $BACKUP_NAME --ns $PROXMOX_BACKUP_SERVER_NAMESPACE
if [[ $? -ne 0 ]]; then
    ERROR_MSG="$(date '+%Y-%m-%d %H:%M:%S') - Backup failed for $BACKUP_DIRECTORY"
    send_notifications "Backup Failed" "$ERROR_MSG"
    echo "$ERROR_MSG"
    exit 1
else
    SUCCESS_MSG="$(date '+%Y-%m-%d %H:%M:%S') - Backup for $BACKUP_DIRECTORY completed successfully."
    echo "$SUCCESS_MSG"
fi
