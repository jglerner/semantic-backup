# Semantic Backup

**Semantic Backup** is a lightweight Linux backup system designed for reliability, transparency, and zero-surprise recovery.

It creates **incremental daily snapshots** of selected directories, keeps them locally, and synchronizes them to an external device when available.

The design philosophy is:

* **Local-first backups**
* **Deterministic snapshots**
* **Minimal dependencies**
* **Transparent filesystem structure**
* **Safe external synchronization**

The project is intentionally simple: it is built entirely around **bash + rsync + systemd**.

---

# Features

### Incremental snapshot engine

Snapshots are stored as dated directories:

```
YYYYMMDD
```

Example:

```
/var/lib/semantic-backup/snapshots/

20260302
20260303
20260304
20260306
```

Snapshots use `rsync --link-dest`, meaning unchanged files are **hard-linked** to previous snapshots.
This provides **incremental storage with full snapshot visibility**.

Each snapshot behaves like a **complete filesystem copy**, while consuming minimal disk space.

---

### Local-first backup strategy

Backups are always created locally first:

```
/var/lib/semantic-backup/snapshots
```

Only after a successful local snapshot does the system:

1. Mount the external backup device
2. Synchronize snapshots
3. Apply retention policies
4. Flush buffers
5. Safely unmount the device

This guarantees that **local recovery is always possible**, even if the external drive is disconnected.

---

### External backup device

External snapshots are stored at:

```
/mnt/semantic_backup/snapshots
```

The external drive is mounted dynamically using its UUID.

Example mount command:

```
mount -U <UUID> /mnt/semantic_backup
```

The drive is automatically unmounted after synchronization.

---

### Retention policy

Old snapshots are automatically removed.

Default configuration:

```
RETENTION_DAYS=7
```

Snapshots older than the retention period are deleted both:

* locally
* on the external drive

---

### Include / Exclude policy

Backup scope is controlled using two files:

```
include.txt
exclude.txt
```

Typical structure:

```
include.txt
-----------

Documents
Projects
infra
```

```
exclude.txt
-----------

.cache
.local/share/Trash
node_modules
```

These allow precise control of what is backed up.

---

# Commands

### Run backup manually

```
sudo semantic-backup run
```

Example output:

```
Semantic Backup
Creating local snapshot...
Local snapshot complete.
Syncing snapshot to external...
Backup completed successfully.
```

---

### Verify snapshots

```
sudo semantic-backup verify
```

Displays:

* available snapshots
* disk usage
* preview of latest snapshot

---

### Restore a snapshot

```
sudo semantic-backup restore YYYYMMDD
```

Example:

```
sudo semantic-backup restore 20260306
```

---

# Automation

Backups are executed automatically via **systemd timer**.

Service:

```
semantic-backup.service
```

Timer:

```
semantic-backup.timer
```

Example schedule:

```
Daily at 00:00
```

Check timers:

```
systemctl list-timers
```

---

# Snapshot Location

Local snapshots:

```
/var/lib/semantic-backup/snapshots
```

External snapshots:

```
/mnt/semantic_backup/snapshots
```

---

# Project Structure

```
semantic-backup/

semantic-backup        main backup engine
backup-now.sh          helper script for manual runs
include.txt            include policy
exclude.txt            exclude policy
README.md
```

---

# Safety design

The system is intentionally conservative:

* Local snapshot always happens first
* External sync happens second
* Filesystem buffers are flushed
* External drive is safely unmounted

This minimizes the risk of **backup corruption or partial snapshots**.

---

# Version

Current stable version:

```
v0.3.2
```

Highlights:

* Production snapshot engine
* Local-first architecture
* UUID-based external mount
* Filesystem restructuring
* Robust systemd integration

---

# License

MIT License

---

# Author

Jacques Lerner
