#!/bin/bash
set -e

mkdir -p "$DEST"

SOURCE="$HOME/infra"
DEST="/mnt/slotx/snapshots"
TODAY=$(date +%Y%m%d)
TARGET="$DEST/$TODAY"

LAST=$(ls -1 "$DEST" 2>/dev/null | grep -E '^[0-9]{8}$' | sort | tail -n 1)

if [ -d "$TARGET" ]; then
    echo "Snapshot for today already exists. Aborting."
    exit 1
fi

if [ -n "$LAST" ] && [ -d "$DEST/$LAST" ]; then
    echo "Using previous snapshot: $LAST"
    rsync -a --delete --link-dest="$DEST/$LAST" "$SOURCE/" "$TARGET/"
else
    echo "No previous snapshot found. Creating full snapshot."
    rsync -a "$SOURCE/" "$TARGET/"
fi

echo "Snapshot complete: $TODAY"
