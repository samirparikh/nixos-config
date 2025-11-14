{ config, pkgs, ... }:

{
  # OpenSSH daemon
  # services.openssh.enable = true;

  # Add other services here as needed

  # enable ifuse to connect to iPhone
  services.usbmuxd.enable = true;

  # enable pipewire
  services.pipewire.enable = true;
  services.pipewire.alsa.enable = true;
  services.pipewire.alsa.support32Bit = true;
  services.pipewire.pulse.enable = true;
  security.rtkit.enable = true;

}
