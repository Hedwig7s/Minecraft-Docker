#!/usr/bin/env nu

# ==============================
# Global config
# ==============================
version

# --- Btrfs Backup Config ---
let BACKUP_ENABLED = ($env.BACKUP_ENABLED? | default "false")
let BACKUP_DEST = ($env.BACKUP_DEST? | default "/backups")
let BACKUP_INTERVAL = ($env.BACKUP_INTERVAL? | default 21600 | into int) # 6 hours
let BACKUP_COUNT = ($env.BACKUP_COUNT? | default 5 | into int)
# ---------------------------
let MCDIR = ($env.MCDIR? | default "/data")
$env.MCDIR = $MCDIR

try {
    mkdir $MCDIR
    cd $MCDIR
} catch {
    print $"Error: Could not access or create directory ($MCDIR)"
    exit 1
}

# ==============================
# Btrfs Backup & Rotation Logic
# ==============================

def perform_btrfs_backup [BACKUP_ENABLED, BACKUP_DEST, BACKUP_INTERVAL, BACKUP_COUNT, MCDIR] {
    if $BACKUP_ENABLED != "true" {
        return
    }

    # 1. Validation
    if not ($BACKUP_DEST | path exists) {
        print $"Btrfs: Backup destination ($BACKUP_DEST) not found. skipping."
        return
    }

    # 2. Check timing
    let last_backup_file = $"($BACKUP_DEST)/.last_backup_timestamp"
    let current_time = (date now | into int) / 1_000_000_000 | into int
    mut do_backup = false

    if ($last_backup_file | path exists) {
        let last_time = (open $last_backup_file | into int)
        let elapsed = $current_time - $last_time
        if $elapsed >= $BACKUP_INTERVAL {
            $do_backup = true
        } else {
            let mins_left = (($BACKUP_INTERVAL - $elapsed) / 60 | into int)
            print $"Btrfs: Last backup is recent. Next backup in ~($mins_left)m."
        }
    } else {
        $do_backup = true
    }

    # 3. Execution
    if $do_backup {
        let snapshot_name = $"mc_snap_(date now | format date '%Y%m%d_%H%M%S')"
        print $"Btrfs: Creating snapshot ($snapshot_name)..."

        let result = (do { btrfs subvolume snapshot -r $MCDIR $"($BACKUP_DEST)/($snapshot_name)" } | complete)

        if $result.exit_code == 0 {
            $current_time | into string | save -f $last_backup_file

            # 4. Rotation Logic (keep only X newest)
            let snapshots = (ls $"($BACKUP_DEST)/mc_snap_*" | sort-by name | get name)
            let count = ($snapshots | length)

            if $count > $BACKUP_COUNT {
                let to_remove = $count - $BACKUP_COUNT
                print $"Btrfs: Rotating backups. Removing ($to_remove) oldest snapshot\(s\)..."
                for snap in ($snapshots | first $to_remove) {
                    btrfs subvolume delete $snap
                }
            }
        } else {
            print "Btrfs Error: Failed to create snapshot. Check CAP_SYS_ADMIN privileges."
        }
    }
}

# Run backup check
perform_btrfs_backup $BACKUP_ENABLED $BACKUP_DEST $BACKUP_INTERVAL $BACKUP_COUNT $MCDIR

chown -R minecraft:minecraft $MCDIR
exec gosu minecraft /nonroot.nu
