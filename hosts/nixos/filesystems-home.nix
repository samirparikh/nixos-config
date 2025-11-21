{ config, lib, pkgs, ... }:

{
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/f4aa8ad6-e4af-4796-969a-6b2fae9aad15";
    fsType = "btrfs";
    options = [ "subvol=@home" ];
  };

}
