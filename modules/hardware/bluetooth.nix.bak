{ config, lib, pkgs, ... }:

with lib;

{
  options.mySystem.hardware.bluetooth = {
    enable = mkEnableOption "Bluetooth support";
  };

  config = mkIf config.mySystem.hardware.bluetooth.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;
  };
}
