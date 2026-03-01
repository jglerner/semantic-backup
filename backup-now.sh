#!/bin/bash
set -e

SOURCE="$HOME/infra"
DEST="/mnt/slotx/snapshots"

mkdir -p "$DEST"

TODAY=$(date +%Y%m%d)
TARGET="$DEST/$TODAY"

LAST=$(ls -1 "$DEST" 2>/dev/null | grep -E '^[0-9]{8}$' | sort | tail -n 1)

if [ -d "$TARGET" ]; then
    echo "Snapshot for today already exists. Aborting."
    exit 0
fi

if [ -n "$LAST" ] && [ -d "$DEST/$LAST" ]; then
    echo "Using previous snapshot: $LAST"
    rsync -a --delete \
        --exclude-from="$SOURCE/exclude.txt" \
        --link-dest="$DEST/$LAST" \
        "$SOURCE/" "$TARGET/"
else
    echo "No previous snapshot found. Creating full snapshot."
    rsync -a \
        --exclude-from="$SOURCE/exclude.txt" \
        "$SOURCE/" "$TARGET/"
fi

echo "Snapshot complete: $TODAY"
