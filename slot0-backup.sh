#!/bin/bash
# slot0-backup.sh — Unified semantic backup for Debian 13 + LMDE7
# Philosophy: backup human meaning, not machine garbage.

# Disk where backups live
DISK="/BACKUP_DISK"

# Sources
SRC_OS1="/"
SRC_OS2="/OS2_MOUNTPOINT"

# Destinations
DEST_OS1="$DISK/slot0/os1"
DEST_OS2="$DISK/slot0/os2"

# Semantically valuable directories
COMMON_DIRS=(
  "home"
  "etc"
  "opt"
  "usr/local"
)

# Semantic excludes (garbage)
EXCLUDES=(
  ".cache/"
  ".mozilla/"
  ".thunderbird/"
  "Downloads/"
  "var/cache/"
  "var/tmp/"
  "tmp/"
  "proc/"
  "sys/"
  "dev/"
  "run/"
  "media/"
  "mnt/"
  "lost+found/"
  "slot1/"
  "slot2/"
  "usr/share/locale/"
  "usr/lib/locale/"
  "usr/share/i18n/"
)

mkdir -p "$DEST_DEB" "$DEST_LMDE"

backup() {
  local SRC="$1"
  local DEST="$2"
  local NAME="$3"

  if [ ! -d "$SRC" ]; then
    echo ">>> Skipping $NAME (source not mounted: $SRC)"
    return 0
  fi

  echo "=== Backing up $NAME ==="

  for d in "${COMMON_DIRS[@]}"; do
    rsync -aAXH --delete \
      $(printf -- "--exclude=%s " "${EXCLUDES[@]}") \
      "$SRC/$d/" "$DEST/$d/"
  done
}

backup "$SRC_DEBIAN13" "$DEST_DEB" "Debian 13"
backup "$SRC_LMDE7"    "$DEST_LMDE" "LMDE 7"

echo "=== Backup done ==="
date +"%a %d %b %Y %T %Z"



