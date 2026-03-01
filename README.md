# Semantic Backup – Engine Layer

## Version: v0.2.0

## Quick Start

1. Mount external device
2. Run:
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

Each snapshot:

- Is created once per day
- Is immutable after creation
- Uses hard links to previous snapshots
- Appears as a full copy
- Consumes space only for changed files

Additional directories:

```
/snapshots/YYYYMMDD/
```

Each snapshot:

- Is created once per day
- Is immutable after creation
- Uses hard links to previous snapshots
- Appears as a full copy
- Consumes space only for changed files

Additional directories:

Each snapshot:

- Is created once per day
- Is immutable after creation
- Uses hard links to previous snapshots
- Appears as a full copy
- Consumes space only for changed files

Additional directories:

