#!/bin/bash

# cron every 1 hour:  0 * * * * bash /path/to/script.sh"

# Configurable variables
BACKUP_ITEMS=(
    # files / folders
    "/path/to/item"
    "/path/to/item"
)

# Exclusions: Add patterns to exclude specific files or directories: other possible choices: "*.log"
EXCLUDE_PATTERNS=(
    "vendor"
    "node_modules"
)

DESTINATION="$(pwd)"

# Log file for backup
LOG_FILE="$DESTINATION/backup.log"

# Timestamp for backup
TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")
# BACKUP_FOLDER="$DESTINATION/backup_$TIMESTAMP"

# Create destination folder
# mkdir -p "$BACKUP_FOLDER" || { echo "Failed to create destination folder: $BACKUP_FOLDER"; exit 1; }
mkdir -p "$DESTINATION" || { echo "Failed to create destination folder: $DESTINATION"; exit 1; }

# Build rsync exclude options
EXCLUDE_ARGS=()
for PATTERN in "${EXCLUDE_PATTERNS[@]}"; do
    EXCLUDE_ARGS+=("--exclude=$PATTERN")
done


# Start backup process
echo "-------------------- New Backup started at $TIMESTAMP --------------------" | tee -a "$LOG_FILE"
for ITEM in "${BACKUP_ITEMS[@]}"; do
    if [ -e "$ITEM" ]; then
        echo "Syncing $ITEM..." | tee -a "$LOG_FILE"
        sudo rsync -r "${EXCLUDE_ARGS[@]}" "$ITEM" "$DESTINATION" |& tee -a "$LOG_FILE"
    else
        echo "Warning: $ITEM does not exist. Skipping..." | tee -a "$LOG_FILE"
    fi
done

# Completion message
echo "Backup completed at $(date "+%Y-%m-%d_%H-%M-%S")" | tee -a "$LOG_FILE"
echo "Backup saved to $DESTINATION" | tee -a "$LOG_FILE"
