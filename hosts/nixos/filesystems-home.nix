# nixos-config/hosts/nixos/filesystems-home.nix
{ config, pkgs, ... }:

{
  fileSystems."/home/samir/Desktop" = {
    device = "/dev/disk/by-uuid/f4aa8ad6-e4af-4796-969a-6b2fae9aad15";
    fsType = "btrfs";
    options = [ "subvol=@home-Desktop" ];
  };

  fileSystems."/home/samir/Documents" = {
    device = "/dev/disk/by-uuid/f4aa8ad6-e4af-4796-969a-6b2fae9aad15";
    fsType = "btrfs";
    options = [ "subvol=@home-Documents" ];
  };

  fileSystems."/home/samir/Music" = {
    device = "/dev/disk/by-uuid/f4aa8ad6-e4af-4796-969a-6b2fae9aad15";
    fsType = "btrfs";
    options = [ "subvol=@home-Music" ];
  };

  fileSystems."/home/samir/Pictures" = {
    device = "/dev/disk/by-uuid/f4aa8ad6-e4af-4796-969a-6b2fae9aad15";
    fsType = "btrfs";
    options = [ "subvol=@home-Pictures" ];
  };

  fileSystems."/home/samir/Videos" = {
    device = "/dev/disk/by-uuid/f4aa8ad6-e4af-4796-969a-6b2fae9aad15";
    fsType = "btrfs";
    options = [ "subvol=@home-Videos" ];
  };

  fileSystems."/home/samir/sites" = {
    device = "/dev/disk/by-uuid/f4aa8ad6-e4af-4796-969a-6b2fae9aad15";
    fsType = "btrfs";
    options = [ "subvol=@home-sites" ];
  };


  fileSystems."/snapshots" = {
    device = "/dev/mapper/luks-a37448bd-4303-407e-b1bd-b78d8ba9c4fa";
    fsType = "btrfs";
    options = [ "subvol=@snapshots" ];
  };

}
