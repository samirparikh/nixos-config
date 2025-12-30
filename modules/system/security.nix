{ config, lib, pkgs, ... }:

{
  # Security settings
  security.sudo.wheelNeedsPassword = true;
  
  # Polkit
  security.polkit.enable = true;

  # RTKit for real-time scheduling
  security.rtkit.enable = true;

  security.pki.certificateFiles = [
    ../../certs/vaultwarden.crt
  ];
}
