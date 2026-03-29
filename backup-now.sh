#!/bin/bash
set -euo pipefail

########################################
# HARDENED ENVIRONMENT
########################################

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

########################################
# SCRIPT LOCATION
########################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

########################################
# CONFIGURATION
########################################

KEEP=3   # exactly 3 snapshots kept on both local disk and pendrive

SOURCE="/home/jglerner"
INCLUDE_FILE="$SCRIPT_DIR/include.txt"
EXCLUDE_FILE="$SCRIPT_DIR/exclude.txt"

LOCAL_BASE="/home/jglerner/infra/snapshots"

MOUNT_POINT="/mnt/semantic_backup"
UUID="f0e81617-0984-4bfc-bc9e-e01624dac735"
EXTERNAL_BASE="$MOUNT_POINT/snapshots"

TODAY=$(date +%Y%m%d)
LOCAL_TODAY="$LOCAL_BASE/$TODAY"
PARTIAL="$LOCAL_BASE/.${TODAY}.partial"   # written here, renamed atomically on success

########################################
# FUNCTIONS
########################################

BACKUP_FAILED=0

send_failure_mail() {
    echo "Semantic backup FAILED on $(hostname) at $(date)" \
        | mail -s "Backup FAILED" jglerner@gmail.com 2>/dev/null || true
}

cleanup() {
    rm -rf "$PARTIAL"
    if mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
        cd /
        sync
        umount "$MOUNT_POINT" || true
    fi
    [ "$BACKUP_FAILED" -eq 1 ] && send_failure_mail
}

trap cleanup EXIT
trap 'BACKUP_FAILED=1' ERR

########################################
# START
########################################

echo "======================================="
echo " Semantic Backup $(date)"
echo "======================================="

########################################
# LOCAL SNAPSHOT
########################################

mkdir -p "$LOCAL_BASE"

if [ -d "$LOCAL_TODAY" ]; then
    echo "Today's snapshot already exists ($TODAY), skipping."
else
    # Most recent completed snapshot → used as hard-link base to save space
    PREVIOUS=$(ls -1d "$LOCAL_BASE"/[0-9]* 2>/dev/null | sort | tail -n 1 || true)

    LINK_DEST=()
    if [ -n "$PREVIOUS" ]; then
        echo "Using previous snapshot as base: $(basename "$PREVIOUS")"
        LINK_DEST=("--link-dest=$PREVIOUS")
    else
        echo "No previous snapshot found. Creating full snapshot."
    fi

    rm -rf "$PARTIAL"
    mkdir -p "$PARTIAL"

    echo "Creating local snapshot..."
    rsync -a \
        "${LINK_DEST[@]}" \
        --files-from="$INCLUDE_FILE" \
        --exclude-from="$EXCLUDE_FILE" \
        "$SOURCE/" \
        "$PARTIAL/"

    mv "$PARTIAL" "$LOCAL_TODAY"
    echo "Local snapshot complete: $LOCAL_TODAY"
fi

# Count-based rotation: remove oldest directories beyond KEEP
echo "Applying local retention (keep $KEEP)..."
ls -1d "$LOCAL_BASE"/[0-9]* 2>/dev/null | sort | head -n "-$KEEP" | xargs -r rm -rf
echo "Local snapshots now: $(ls -1d "$LOCAL_BASE"/[0-9]* 2>/dev/null | wc -l)"

########################################
# EXTERNAL SYNC  (pendrive SLOTX_01)
########################################

mkdir -p "$MOUNT_POINT"
echo "Mounting external drive..."
mount -U "$UUID" "$MOUNT_POINT"

if ! mountpoint -q "$MOUNT_POINT"; then
    echo "ERROR: pendrive failed to mount."
    BACKUP_FAILED=1
    exit 1
fi

echo "External drive mounted."
mkdir -p "$EXTERNAL_BASE"

# Sync the entire local snapshot directory.
# -H preserves hard links across snapshot dirs → space-efficient on the pendrive too.
# --delete removes from pendrive any snapshot that was already rotated out locally.
echo "Syncing all $KEEP snapshots to pendrive (hard-links preserved)..."
rsync -aH --delete \
    "$LOCAL_BASE/" \
    "$EXTERNAL_BASE/"

echo "External sync complete."
sync
cd /

echo "Unmounting pendrive..."
umount "$MOUNT_POINT"
echo "Pendrive safely unmounted."

echo "======================================="
echo " Backup completed successfully $(date)"
echo "======================================="
exit 0
