{ config, pkgs, ... }:

{

  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
   
  users.users.samir.extraGroups = [ "libvirtd" ];
}
