# Semantic Backup System

A human-centered Linux backup system based on meaning, not raw disk cloning.

**Version:** v0.1.0

---

## Overview

This project implements a **semantic backup strategy** for Linux systems.

Instead of imaging entire disks, it preserves only what defines a system’s identity:

- user data
- system configuration
- custom software
- intentional state

It deliberately excludes entropy:

- caches  
- browser data  
- temporary files  
- regenerated system components  

The goal is reproducible system personality — not binary duplication.

---

## Current Release (v0.1.0)

This version provides:

- A Bash-based backup engine (`backup-now.sh`)
- rsync-based incremental backup
- Selective directory preservation
- Clean exclusion policy
- Designed for manual or cron execution

This is the foundational engine.

It is stable, minimal, and intentionally small.

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
- system-generated artifacts

---

## Philosophy

> Backup meaning, not entropy.

A fresh OS install + semantic restore  
should recreate the machine’s personality  
in minutes.

---

## Roadmap

Future versions may include:

- multi-slot rotation logic
- restore automation script
- config-driven inclusion/exclusion rules
- OS1 / OS2 profile separation
- dry-run verification mode
- integrity validation

---

## Restore Model

On a fresh system:

1. Install base OS
2. Clone this repository
3. Run restore mode (reverse rsync)
4. Reboot

The machine becomes *you* again.

---

## Requirements

- bash
- rsync
- cron (optional)

---

## License

MIT

This is not just a script.  
It is a methodology.
