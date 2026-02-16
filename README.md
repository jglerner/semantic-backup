# Semantic Backup System

A human-centered Linux backup system based on meaning, not raw system cloning.

This project implements a **semantic backup strategy** for two operating systems:

- OS1 (primary system)
- OS2 (secondary / experimental system)

Instead of imaging entire disks, it backs up only what matters:
- user data
- system configuration
- custom software

## Philosophy

> Backup *meaning*, not *entropy*.

Caches, browsers, locales, logs, temporary files and regenerated data
are intentionally excluded.

The result:
- small backups
- fast restores
- no garbage
- no vendor lock-in

## Structure

slot0-backup.sh # core backup engine
slot0-cron-wrapper.sh # scheduler + slot rotation


## What is backed up

- /home
- /etc
- /opt
- /usr/local

## What is excluded

- caches
- browsers profiles
- locales
- temporary system directories
- mounted devices

## Slot Rotation

Implements a 3-generation rotation:

slot0 → slot1 → slot2


So you always have:
- current
- previous
- older snapshot

## Restore strategy

On a fresh system:

1. Install base OS
2. Clone this repo
3. Run slot0-backup.sh in reverse (rsync back)
4. Reboot

System personality is restored in minutes.

## Requirements

- bash
- rsync
- cron (optional)

## License

MIT – use, fork, adapt.
This is a methodology, not just a script.

