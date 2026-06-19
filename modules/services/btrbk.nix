{ config, lib, pkgs, ... }:

{
  # ============================================================================
  # btrbk Backup Configuration
  # ============================================================================
  #
  # Backs up btrfs subvolumes to remote server 'blbu' via SSH:
  #   - Daily: @home-Desktop, @home-Documents
  #   - Weekly: @home-Music, @home-Pictures, @home-sites
  #
  # Prerequisites:
  #   1. Generate SSH key: sudo ssh-keygen -t ed25519 -f /root/.ssh/btrbk_ed25519 -N ""
  #   2. Copy public key to remote: ssh-copy-id -i /root/.ssh/btrbk_ed25519.pub queenbee@blbu
  #   3. Create target directory on remote: ssh blbu "sudo mkdir -p /mnt/storage/snapshots/sites"
  #   4. Adjust 'device' below to match your btrfs root partition
  # ============================================================================

  # Mount the btrfs filesystem root (subvolid=5) so btrbk can access all subvolumes
  fileSystems."/mnt/btrfs-root" = {
    # TODO: Adjust this to your actual root device
    # Find it with: findmnt -n -o SOURCE / | xargs -I{} lsblk -no PKNAME {}
    # Or check your existing filesystems-home.nix for the device
    # device = "/dev/disk/by-label/nixos";
    device = "/dev/disk/by-uuid/f4aa8ad6-e4af-4796-969a-6b2fae9aad15";
    fsType = "btrfs";
    options = [
      "subvolid=5"
      "noatime"
      "compress=zstd"
    ];
  };

  services.btrbk.instances = {
    # -------------------------------------------------------------------------
    # Daily backups: Desktop and Documents
    # -------------------------------------------------------------------------
    daily = {
      onCalendar = "*-*-* 10:45:00";
      settings = {
        timestamp_format = "long";
        ssh_identity = "/root/.ssh/btrbk_ed25519";
        ssh_user = "queenbee";

        # Use compression for transfer
        stream_compress = "zstd";
        stream_compress_level = "3";

        # Local snapshot retention
        snapshot_preserve_min = "2d";
        snapshot_preserve = "7d";

        # Remote backup retention: keep 7 daily, 4 weekly, 3 monthly
        target_preserve_min = "no";
        target_preserve = "7d 4w 3m";

        volume."/mnt/btrfs-root" = {
          snapshot_dir = ".snapshots";

          subvolume."@home-Desktop" = {
            snapshot_name = "Desktop";
            target = "ssh://blbu/mnt/storage/snapshots/Desktop";
          };

          subvolume."@home-Documents" = {
            snapshot_name = "Documents";
            target = "ssh://blbu/mnt/storage/snapshots/Documents";
          };
        };
      };
    };

    # -------------------------------------------------------------------------
    # Weekly backups: Pictures, Music and sites
    # -------------------------------------------------------------------------
    weekly = {
      onCalendar = "Mon *-*-* 13:00:00";
      settings = {
        timestamp_format = "long";
        ssh_identity = "/root/.ssh/btrbk_ed25519";
        ssh_user = "queenbee";

        stream_compress = "zstd";
        stream_compress_level = "3";

        # Local snapshot retention for weekly backups
        snapshot_preserve_min = "2d";
        snapshot_preserve = "4w";

        # Remote backup retention: keep 4 weekly, 6 monthly
        target_preserve_min = "no";
        target_preserve = "4w 6m";

        volume."/mnt/btrfs-root" = {
          snapshot_dir = ".snapshots";

          subvolume."@home-Music" = {
            snapshot_name = "Music";
            target = "ssh://blbu/mnt/storage/snapshots/Music";
          };

          subvolume."@home-Pictures" = {
            snapshot_name = "Pictures";
            target = "ssh://blbu/mnt/storage/snapshots/Pictures";
          };

          subvolume."@home-sites" = {
            snapshot_name = "sites";
            target = "ssh://blbu/mnt/storage/snapshots/sites";
          };
        };
      };
    };
  };

  # Useful for manual runs and debugging
  environment.systemPackages = [ pkgs.btrbk ];

  # ---------------------------------------------------------------------------
  # Notifications via ntfy using wrapper script
  # ---------------------------------------------------------------------------
  
  # Install the wrapper script
  environment.etc."btrbk/btrbk-notify.sh" = {
    source = ./btrbk-notify.sh;
    mode = "0755";
  };

  # Override btrbk services to use the wrapper script and run as root
  systemd.services.btrbk-daily = {
    serviceConfig.ExecStart = lib.mkForce [
      ""  # Clear the default ExecStart
      "${pkgs.bash}/bin/bash /etc/btrbk/btrbk-notify.sh daily /etc/btrbk/daily.conf"
    ];
    serviceConfig.User = lib.mkForce "root";
    serviceConfig.Group = lib.mkForce "root";
    path = [ pkgs.btrbk pkgs.curl pkgs.gnugrep pkgs.gnused pkgs.coreutils ];
  };

  systemd.services.btrbk-weekly = {
    serviceConfig.ExecStart = lib.mkForce [
      ""
      "${pkgs.bash}/bin/bash /etc/btrbk/btrbk-notify.sh weekly /etc/btrbk/weekly.conf"
    ];
    serviceConfig.User = lib.mkForce "root";
    serviceConfig.Group = lib.mkForce "root";
    path = [ pkgs.btrbk pkgs.curl pkgs.gnugrep pkgs.gnused pkgs.coreutils ];
  };

  systemd.timers.btrbk-daily.timerConfig.WakeSystem = true;
  systemd.timers.btrbk-weekly.timerConfig.WakeSystem = true;
}
