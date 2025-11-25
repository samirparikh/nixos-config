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
    timerSchedule = "10:00";
  };

  # Retry logic for transient network failures
  systemd.services.btrfs-backup = {
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "2min";
      StartLimitIntervalSec = "30min";
      StartLimitBurst = 3;
    };
  };
}
