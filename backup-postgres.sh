#!/bin/bash

BACKUP_DIR="/backups"
TIMESTAMP=$(date +"%Y%m%d%H%M%S")

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Function to upload backup to PBS
upload_to_pbs() {
    local file="$1"
    echo "Uploading $file to PBS..."
    proxmox-backup-client backup "$file" --repository "$PBS_REPOSITORY"
}

# PostgreSQL Backup
if [ -n "$POSTGRES_HOST" ]; then
    echo "Backing up PostgreSQL database $POSTGRES_HOST..."
    PGPASSWORD="$POSTGRES_PASSWORD" pg_dumpall -h "$POSTGRES_HOST" -U "$POSTGRES_USER" > "$BACKUP_DIR/postgres-backup-$TIMESTAMP.sql"
    upload_to_pbs "$BACKUP_DIR/postgres-backup-$TIMESTAMP.sql"
else
    echo "POSTGRES_HOST is missing"
    exit 1
fi

echo "Backup process completed."
