#!/bin/bash
set -euo pipefail

### CONFIG ###
RETENTION_DAYS=7
SOURCE="$HOME"
EXCLUDE_FILE="$HOME/infra/engine/exclude.txt"

LOCAL_BASE="$HOME/infra/snapshots"
EXTERNAL_BASE="/media/jglerner/SLOTX_01/snapshots"
MOUNT_POINT="/media/jglerner/SLOTX_01"

TODAY=$(date +%Y%m%d)
LOCAL_TODAY="$LOCAL_BASE/$TODAY"

echo "=== Semantic Backup $(date) ==="

mkdir -p "$LOCAL_BASE"

# If today's snapshot already exists, exit cleanly
if [ -d "$LOCAL_TODAY" ]; then
    echo "Snapshot for today already exists."
    exit 0
fi

# Find previous local snapshot
PREVIOUS=$(ls -1 "$LOCAL_BASE" 2>/dev/null | sort | tail -n 1 || true)

if [ -n "$PREVIOUS" ] && [ -d "$LOCAL_BASE/$PREVIOUS" ]; then
    echo "Using previous snapshot: $PREVIOUS"
    LINK_DEST="--link-dest=$LOCAL_BASE/$PREVIOUS"
else
    echo "No previous snapshot found. Creating full snapshot."
    LINK_DEST=""
fi

# Create local incremental snapshot
echo "Creating local snapshot..."

rsync -a \
    --delete \
    $LINK_DEST \
    --files-from="$HOME/infra/engine/include.txt" \
    "$SOURCE/" \
    "$LOCAL_TODAY"

echo "Local snapshot complete."

# Retention (local)
echo "Applying local retention policy..."
find "$LOCAL_BASE" -mindepth 1 -maxdepth 1 -type d -mtime +$RETENTION_DAYS -exec rm -rf {} +

# External mirror if mounted
if mountpoint -q "$MOUNT_POINT"; then
    echo "External drive mounted. Syncing..."
    mkdir -p "$EXTERNAL_BASE"
    rsync -a --delete "$LOCAL_TODAY" "$EXTERNAL_BASE/"
    echo "External sync complete."

    echo "Applying external retention policy..."
    find "$EXTERNAL_BASE" -mindepth 1 -maxdepth 1 -type d -mtime +$RETENTION_DAYS -exec rm -rf {} +
else
    echo "External drive not mounted. Skipping external sync."
fi

echo "=== Backup Completed Successfully ==="
exit 0
