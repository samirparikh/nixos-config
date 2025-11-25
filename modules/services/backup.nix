{ config, pkgs, lib, ... }:

{
  services.btrfs-backup = {
    enable = true;
    
    # SSH Configuration
    sshHost = "target";
    sshUser = "samir";
    sshConfig = "/home/samir/.ssh/config";
    
    # Paths
    remotePath = "/mnt/storage/snapshots";
    localSnapshotPath = "/snapshots";
    
    # Subvolumes
    subvolumes = {
      Desktop = "/home/samir/Desktop";
      Documents = "/home/samir/Documents";
      Music = "/home/samir/Music";
      Pictures = "/home/samir/Pictures";
      Videos = "/home/samir/Videos";
    };
    
    # Retention
    localRetentionDays = 7;
    remoteRetentionDays = 30;
    
    # Logging
    logFile = "/var/log/btrfs-backup.log";

    enableTimer = true;
    timerSchedule = "03:00";
  };

  # Wake system from sleep for backup
  systemd.timers.btrfs-backup = {
    timerConfig = {
      WakeSystem = true;
    };
  };

  # Handle resume timing and add retry logic
  systemd.services.btrfs-backup = {
    serviceConfig = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 30";
      Restart = "on-failure";
      RestartSec = "2min";
      StartLimitIntervalSec = "30min";
      StartLimitBurst = 3;
    };
  };
}
