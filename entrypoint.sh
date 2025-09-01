#!/bin/bash

# Entrypoint script for PBS K8s Backup container
# Supports multiple backup modes and custom commands

set -e

# Function to show usage
show_usage() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  pvcs        - Backup PVCs (default)"
    echo "  postgres    - Backup PostgreSQL database"
    echo "  bash        - Start interactive bash shell"
    echo "  <custom>    - Execute custom command"
    echo ""
    echo "Environment Variables:"
    echo "  For PVC backups:"
    echo "    PVC_HOST_PATH                    - Path to PVCs (default: /pvcs)"
    echo "    PROXMOX_BACKUP_SERVER_NAMESPACE  - PBS namespace"
    echo "    PROXMOX_BACKUP_SERVER_PASSWORD   - PBS password"
    echo "    PROXMOX_BACKUP_SERVER_FINGERPRINT - PBS fingerprint"
    echo "    PROXMOX_BACKUP_SERVER_REPOSITORY - PBS repository"
    echo "    TELEGRAM_BOT_TOKEN               - Telegram bot token"
    echo "    TELEGRAM_CHAT_ID                 - Telegram chat ID"
    echo ""
    echo "  For PostgreSQL backups:"
    echo "    BACKUP_NAME                      - Backup identifier"
    echo "    POSTGRES_HOST                    - PostgreSQL host"
    echo "    POSTGRES_USER                    - PostgreSQL user"
    echo "    POSTGRES_PASSWORD                - PostgreSQL password"
    echo "    (plus all PBS variables above)"
}

# Default command
COMMAND="${1:-pvcs}"

case "$COMMAND" in
    "pvcs")
        echo "Starting PVC backup..."
        exec /backup-pvcs.sh
        ;;
    "postgres")
        echo "Starting PostgreSQL backup..."
        exec /backup-postgres.sh
        ;;
    "bash")
        echo "Starting interactive bash shell..."
        exec /bin/bash
        ;;
    "help"|"--help"|"-h")
        show_usage
        exit 0
        ;;
    *)
        echo "Executing custom command: $*"
        exec "$@"
        ;;
esac