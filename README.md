Semantic Backup – Engine Layer

Minimal deterministic snapshot backup system for Linux.
Inspired by the simplicity of `rsync` and the reliability of
date-based immutable snapshots.

## Version 0.3.1

Refactored to local-first incremental snapshot engine.
Minor inconsistencies corrected (2026-03-05)

## Quick Start

1. Mount the external device

2. Run the backup:

```bash
./backup-now.sh
---

## Overview

This directory contains the core backup engine of the Semantic Backup System.

It implements a deterministic, immutable, date-based snapshot model using
`rsync` with hard-link support.

The system is designed for:

- Reliable incremental backups
- Storage-efficient snapshots
- Clear recovery structure
- Minimal complexity
- Predictable behavior

---

## Architecture

### Storage Layout (External Device)

Each snapshot is stored as a date-based directory:

`/snapshots/YYYYMMDD/`

Characteristics:

- One snapshot is created per day
- Snapshots are immutable once created
- Hard links are used to reference unchanged files
- Each snapshot appears as a full filesystem copy
- Disk space is consumed only by changed files

This structure allows fast browsing and simple recovery without
special tools.

### Additional Directories

The system relies on a small number of predictable directories:

Local snapshot storage:

`/home/<user>/infra/snapshots/`

This directory contains the primary snapshot chain created on the
local system.

External backup device:

`/mnt/semantic_backup/snapshots/`

When an external device is available, the newest snapshot is synced
to the external storage for redundancy.

### Retention Policy

Snapshots are retained for a configurable number of days.
Older snapshots are automatically removed during each run.

This keeps storage usage predictable while preserving recent
recovery points.

### Recovery

Because each snapshot appears as a full filesystem tree,
files can be restored simply by copying them back from the
desired snapshot directory.
