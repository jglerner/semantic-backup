#!/bin/bash

START_TIME=$(date +%s)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXCLUDE_FILE="$SCRIPT_DIR/exclude.txt"

if [ ! -f "$EXCLUDE_FILE" ]; then
    echo "ERROR: exclude.txt not found."
    exit 1
fi

EXCLUDE_OPTS="--exclude-from=$EXCLUDE_FILE"

OS1_SRC="$HOME"
OS2_SRC="$HOME/mnt/ldme7/home"

MOUNT_BASE="/media/$USER"
DEVICE_LABEL="SLOTX_01"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
else
    BRANCH="no-git"
fi

BASE_DST="$MOUNT_BASE/$DEVICE_LABEL/$BRANCH"

if ! mountpoint -q "$MOUNT_BASE/$DEVICE_LABEL"; then
    echo "ERROR: $DEVICE_LABEL not mounted."
    exit 1
fi

if mountpoint -q "$HOME/infra/system-backups/mnt/ldme7"; then
    DO_OS2=1
else
    DO_OS2=0
    echo "OS2 not mounted — skipping."
fi

RSYNC_OPTS="-avh --delete --partial --info=progress2"

elapsed() {
    NOW=$(date +%s)
    echo "$(( (NOW - START_TIME) / 60 )) min"
}

size_of() {
    du -sh "$1" 2>/dev/null | cut -f1
}

move_specials() {
    SRC="$1"
    DST="$2"

    mkdir -p "$DST/APK" "$DST/APPIMAGE" "$DST/ANDROID"

    shopt -s nullglob

    for f in "$SRC"/*.apk; do
        rsync -avh --ignore-existing "$f" "$DST/APK/"
    done

    for f in "$SRC"/*.AppImage; do
        rsync -avh --ignore-existing "$f" "$DST/APPIMAGE/"
    done

    if [ -d "$SRC/Android" ]; then
        rsync -avh --ignore-existing "$SRC/Android/" "$DST/ANDROID/"
    fi

    shopt -u nullglob
}

backup_home() {
    SRC="$1"
    DST="$2"
    NAME="$3"

    echo "=============================="
    echo "Backing up $NAME"
    echo "Source size: $(size_of "$SRC")"
    echo "Destination: $DST"
    echo "=============================="

    mkdir -p "$DST"

    rsync $RSYNC_OPTS $EXCLUDE_OPTS "$SRC/" "$DST/"
    rc=$?

    if [ "$rc" -eq 23 ]; then
        echo "Warning: rsync partial transfer (code 23) – likely live file changes."
        rc=0
    fi

    if [ "$rc" -ne 0 ]; then
        exit "$rc"
    fi

    echo "Finished $NAME in $(elapsed)"
    echo
}

backup_home "$OS1_SRC" "$BASE_DST/OS1" "OS1"
move_specials "$OS1_SRC" "$BASE_DST/OS1"

if [ "$DO_OS2" -eq 1 ]; then
    backup_home "$OS2_SRC" "$BASE_DST/OS2" "OS2"
    move_specials "$OS2_SRC" "$BASE_DST/OS2"
fi

END_TIME=$(date +%s)
TOTAL_SEC=$((END_TIME - START_TIME))

HOURS=$((TOTAL_SEC / 3600))
MINUTES=$(((TOTAL_SEC % 3600) / 60))
SECONDS=$((TOTAL_SEC % 60))

if [ "$HOURS" -gt 0 ]; then
    DURATION="${HOURS}h ${MINUTES}m ${SECONDS}s"
elif [ "$MINUTES" -gt 0 ]; then
    DURATION="${MINUTES}m ${SECONDS}s"
else
    DURATION="${SECONDS}s"
fi

echo "======================================="
echo "BACKUP COMPLETED"
echo "Total time: $DURATION"
echo "OS1 size: $(size_of "$BASE_DST/OS1")"
[ "$DO_OS2" -eq 1 ] && echo "OS2 size: $(size_of "$BASE_DST/OS2")"
echo "======================================="
