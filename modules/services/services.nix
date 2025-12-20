{ config, pkgs, ... }:

{
  # OpenSSH daemon
  # services.openssh.enable = true;

  # Add other services here as needed

  # enable ifuse to connect to iPhone
  services.usbmuxd.enable = true;

  # enable tailscale
  services.tailscale.enable = true;

  # allow incoming TCP connections to port 8000
  networking.firewall.allowedTCPPorts = [ 8000 ];

  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };
}
