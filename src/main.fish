#!/usr/bin/env fish
# ==============================
# Global config
# ==============================
fish --version
# --- Btrfs Backup Config ---
set -q BACKUP_ENABLED; or set BACKUP_ENABLED false
set -q BACKUP_DEST; or set BACKUP_DEST /backups
set -q BACKUP_INTERVAL; or set BACKUP_INTERVAL 21600 # Default: 6 hours
set -q BACKUP_COUNT; or set BACKUP_COUNT 5            # Keep last 5
# ---------------------------
set -q MCDIR; or set -gx MCDIR /data

if not mkdir -p $MCDIR; or not cd $MCDIR
    echo "Error: Could not access or create directory $MCDIR"
    exit 1
end
# ==============================
# Btrfs Backup & Rotation Logic
# ==============================

function perform_btrfs_backup
    if test "$BACKUP_ENABLED" != "true"
        return
    end

    # 1. Validation
    if not test -d "$BACKUP_DEST"
        echo "Btrfs: Backup destination $BACKUP_DEST not found. skipping."
        return
    end

    # 2. Check timing
    set last_backup_file "$BACKUP_DEST/.last_backup_timestamp"
    set current_time (date +%s)
    set do_backup 0

    if test -f "$last_backup_file"
        set last_time (cat "$last_backup_file")
        set elapsed (math "$current_time - $last_time")
        if test "$elapsed" -ge "$BACKUP_INTERVAL"
            set do_backup 1
        else
            set mins_left (math "($BACKUP_INTERVAL - $elapsed) / 60")
            echo "Btrfs: Last backup is recent. Next backup in ~"$mins_left"m."
        end
    else
        set do_backup 1
    end

    # 3. Execution
    if test "$do_backup" -eq 1
        set snapshot_name "mc_snap_"(date +%Y%m%d_%H%M%S)
        echo "Btrfs: Creating snapshot $snapshot_name..."

        if btrfs subvolume snapshot -r "$MCDIR" "$BACKUP_DEST/$snapshot_name"
            echo "$current_time" > "$last_backup_file"

            # 4. Rotation Logic (Keep only X newest)
            # List snapshots, sort them, and delete the oldest if over limit
            set snapshots (ls -d $BACKUP_DEST/mc_snap_* 2>/dev/null | sort)
            set count (count $snapshots)

            if test "$count" -gt "$BACKUP_COUNT"
                set to_remove (math "$count - $BACKUP_COUNT")
                echo "Btrfs: Rotating backups. Removing $to_remove oldest snapshot(s)..."
                for i in (seq $to_remove)
                    btrfs subvolume delete "$snapshots[$i]"
                end
            end
        else
            echo "Btrfs Error: Failed to create snapshot. Check CAP_SYS_ADMIN privileges."
        end
    end
end

# Run backup check
perform_btrfs_backup

chown -R minecraft:minecraft $MCDIR
exec gosu minecraft /nonroot.fish
