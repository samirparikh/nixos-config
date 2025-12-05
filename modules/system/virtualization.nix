{ config, pkgs, ... }:

{

  # virt manager configuration
  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  # podman configuration
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      # Required for containers under podman-compose to be
      # able to talk to each other
      defaultNetwork.settings.dns_enabled = true;
    };
  };
   
  users.users.samir = {
    extraGroups = [
#      "libvirtd"
      "podman"
    ];
  };
}
