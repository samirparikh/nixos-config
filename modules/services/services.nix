{ config, pkgs, ... }:

{
  # OpenSSH daemon
  # services.openssh.enable = true;

  # Add other services here as needed

  # enable ifuse to connect to iPhone
  services.usbmuxd.enable = true;

  # enable tailscale
  services.tailscale.enable = true;
}
