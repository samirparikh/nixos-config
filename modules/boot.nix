{ config, pkgs, ... }:

{
  # Bootloader configuration
  # boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";  # don't write to MBR
  boot.loader.grub.efiSupport = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
