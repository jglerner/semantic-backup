# Semantic Backup System

A human-centered Linux backup system based on meaning, not raw disk cloning.

**Version:** v0.1.0

---

## Overview

Semantic Backup System implements a **meaning-oriented backup strategy** for Linux systems.

Instead of cloning entire disks, it preserves only what defines a system’s identity:

- user data
- system configuration
- custom software
- intentional state

It deliberately excludes entropy:

- caches
- browser data
- temporary files
- regenerated system components
- system noise

The objective is reproducible system personality — not binary duplication.

---

## Current Release (v0.1.0)

This release provides:

- A Bash-based backup engine (`backup-now.sh`)
- rsync-based incremental synchronization
- OS1 / OS2 separation logic
- Clean exclusion policy
- Human-readable execution reporting
- Designed for manual execution or systemd integration

This is the foundational engine.

Stable. Minimal. Intentional.

---

## What Is Backed Up

- `/home`
- `/etc`
- `/opt`
- `/usr/local`

---

## What Is Excluded

- caches
- browser profiles
- locales
- temporary directories
- mounted devices
- regenerated system artifacts

---

## Philosophy

> Backup meaning, not entropy.

A fresh OS installation + semantic restore  
should recreate the machine’s personality  
in minutes.

Small backups.  
Fast restores.  
No garbage.  
No vendor lock-in.

---

## Restore Model

On a fresh system:

1. Install base OS
2. Clone this repository
3. Run restore mode (reverse rsync)
4. Reboot

The machine becomes *you* again.

---

## Roadmap

Future versions may include:

- multi-slot rotation logic
- restore automation script
- config-driven inclusion/exclusion rules
- integrity verification
- dry-run validation mode
- extended OS profile abstraction

---

## Requirements

- bash
- rsync
- systemd (optional)
- cron (optional)

---

## License

MIT

This project is not just a script.  
It is a methodology.
