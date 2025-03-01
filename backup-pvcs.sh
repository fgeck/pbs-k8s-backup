!#/bin/bash

required_vars=("PVC_HOST_PATH" "PROXMOX_BACKUP_SERVER_NAMESPACE" "PROXMOX_BACKUP_SERVER_PASSWORD" "PROXMOX_BACKUP_SERVER_FINGERPRINT" "PROXMOX_BACKUP_SERVER_REPOSITORY" "TELEGRAM_BOT_TOKEN" "TELEGRAM_CHAT_ID")

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


for dir in $(ls -d ./*); do
    # Remove the trailing slash from the directory name
    backup_dir=${dir%/}
    backup_name=$(echo "$backup_dir" | awk -F'_' '{print $2 "_" $3}')
    echo "Backing up directory: $backup_dir with name $backup_name"

    export PBS_FINGERPRINT=$PROXMOX_BACKUP_SERVER_FINGERPRINT
    export PBS_PASSWORD=$PROXMOX_BACKUP_SERVER_PASSWORD
    proxmox-backup-client backup "$backup_name.pxar:$backup_dir" --repository "$PROXMOX_BACKUP_SERVER_REPOSITORY" --backup-id $backup_name --ns "$PROXMOX_BACKUP_SERVER_NAMESPACE"
    if [[ $? -ne 0 ]]; then
    ERROR_MSG="$(date '+%Y-%m-%d %H:%M:%S') - Backup failed for $backup_dir"
        send_telegram_message "$ERROR_MSG"
        echo "$ERROR_MSG"
        exit 1
    else
        SUCCESS_MSG="$(date '+%Y-%m-%d %H:%M:%S') - Backup for $backup_dir completed successfully."
        echo "$SUCCESS_MSG"
        # send_telegram_message "$SUCCESS_MSG"
    fi
    sleep 1
done
