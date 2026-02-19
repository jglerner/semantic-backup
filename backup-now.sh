#!/bin/bash
# backup-now.sh - Incremental semantic backup with progress + sleep lock

#if [ -z "$INHIBITED" ]; then
#    export INHIBITED=1
#    exec systemd-inhibit --what=idle:sleep --why="Running backup-now.sh" "$0" "$@"
#fi

#set -e

START_TIME=$(date +%s)

# --- Sources ---
OS1_SRC="$HOME"
OS2_SRC="$HOME/mnt/ldme7/home"

# --- Destination ---
BASE_DST="/media/jglerner/KINGSTON/slot0"

# --- Safety checks ---
if [ ! -d "/media/jglerner/KINGSTON" ]; then
    echo "ERROR: KINGSTON not mounted."
    exit 1
fi

#20260218
#if [ ! -d "$OS2_SRC" ]; then
#    echo "WARNING: OS2 not mounted, skipping OS2."
#    DO_OS2=0
#else
#    DO_OS2=1
#fi

if mountpoint -q "$HOME/mnt/ldme7"; then
    DO_OS2=1
else
    DO_OS2=0
    echo "OS2 not mounted — skipping."
fi

#20260218  end

# --- Exclusions ---
EXCLUDE=(
    "mnt/"
    "media/"
    "timeshift/"
    "lost+found/"
    ".cache/"
    ".mozilla/cache/"
    ".npm/"
    ".gradle/"
    ".rustup/"
    ".cargo/"
    ".local/share/Trash/"
    ".config/google-chrome/OptGuideOnDeviceModel/"
    "git-backups/"
    "github-backup/"
    "RESTORE/"
    "*.log"
    "*.tmp"
)

EXCLUDE_OPTS=""
for e in "${EXCLUDE[@]}"; do
    EXCLUDE_OPTS+=" --exclude=$e"
done

# --- Rsync options ---
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

    rsync -avh --ignore-existing "$SRC"/*.apk "$DST/APK/" 2>/dev/null
    rsync -avh --ignore-existing "$SRC"/*.AppImage "$DST/APPIMAGE/" 2>/dev/null

    if [ -d "$SRC/Android" ]; then
        rsync -avh --ignore-existing "$SRC/Android/" "$DST/ANDROID/"
    fi
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

#20260218

rsync $RSYNC_OPTS $EXCLUDE_OPTS "$SRC/" "$DST/"
rc=$?

if [ "$rc" -eq 23 ]; then
    echo "Warning: rsync partial transfer (code 23) – likely live file changes."
    rc=0
fi

if [ "$rc" -ne 0 ]; then
    return "$rc"
fi

    echo "Finished $NAME in $(elapsed)"
    echo

#20260218 end

}

# ================= RUN =================

backup_home "$OS1_SRC" "$BASE_DST/OS1" "OS1"
move_specials "$OS1_SRC" "$BASE_DST/OS1"

if [ "$DO_OS2" -eq 1 ]; then
    backup_home "$OS2_SRC" "$BASE_DST/OS2" "OS2"
    move_specials "$OS2_SRC" "$BASE_DST/OS2"
fi

END_TIME=$(date +%s)
TOTAL_MIN=$(( (END_TIME - START_TIME) / 60 ))

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
