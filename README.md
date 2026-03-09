# Semantic Backup

**Semantic Backup** is a lightweight Linux backup system built around `rsync` snapshotting.

It creates incremental snapshots of selected parts of a user's home directory, stores them locally, and optionally synchronizes them to an external device.

The goal is simple:

**Provide reliable, transparent backups that make rebuilding a personal Linux environment straightforward after a system failure.**

The project intentionally remains minimal and is built using only:

* Bash
* rsync
* systemd (optional for automation)

---

# Design Philosophy

Semantic Backup follows a few simple principles:

* **Local-first backups**
* **Deterministic filesystem snapshots**
* **Minimal dependencies**
* **Transparent and inspectable backup structure**
* **Safe external synchronization**

The system focuses on preserving **meaningful user data**, not full system images.

---

# Features

### Incremental snapshots

Snapshots are stored as dated directories:

```
YYYYMMDD
```

Example:

```
snapshots/

20260302
20260303
20260304
20260306
```

Snapshots use `rsync --link-dest`, which means unchanged files are **hard-linked** to previous snapshots.
Each snapshot appears as a **complete filesystem copy**, while using minimal additional disk space.

---

### Local-first backup strategy

Snapshots are always created locally first.

Example local storage location:

```
/var/lib/semantic-backup/snapshots
```

After the local snapshot is successfully created, the system may:

1. Mount the external backup device
2. Synchronize snapshots
3. Apply retention policies
4. Flush filesystem buffers
5. Safely unmount the device

This guarantees that **local recovery remains possible even if the external drive is unavailable**.

---

### External backup synchronization

External snapshots may be stored at:

```
/mnt/semantic_backup/snapshots
```

The external device is mounted dynamically using its UUID and automatically unmounted after synchronization.

---

### Retention policy

Old snapshots are automatically removed.

Example configuration:

```
RETENTION_DAYS=7
```

Snapshots older than the retention period are deleted both:

* locally
* on the external device

---

# Repository Structure

```
semantic-backup/

backup-now.sh        main backup script
include.txt          include policy
exclude.txt          exclude policy
README.md
.gitignore
```

---

# Backup Scope

Backup scope is defined using two configuration files.

### include.txt

Defines directories or files to include in the backup.

Example:

```
Documents/
Projects/
infra/engine/

.gitconfig
.ssh/
```

Paths are relative to the user's home directory.

---

### exclude.txt

Defines paths that should be excluded from backup.

Example:

```
.cache
.local/share/Trash
node_modules
```

These files allow precise control over the backup scope.

---

# Running a Backup

Run the backup manually:

```
./backup-now.sh
```

Automation can be implemented using a `systemd` timer or a cron job.

---

# Snapshot Structure

Snapshots behave like normal directories and can be browsed directly.

Example:

```
snapshots/

20260306/
20260307/
20260308/
```

Each directory represents a complete view of the filesystem at that point in time.

---

# Restoring Files

Because snapshots are regular directories, files can be restored using standard tools.

Example:

```
rsync -a snapshots/20260309/ ~/
```

Or by manually copying files from a specific snapshot.

---

# Philosophy

Semantic Backup focuses on backing up **what matters**, rather than copying entire systems.

Typical preserved data includes:

* personal documents
* projects
* configuration files
* infrastructure scripts

This approach keeps backups **small, fast, and easy to restore**.

---

# License

MIT License

---

# Author

Jacques Lerner

