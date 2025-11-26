{ config, lib, pkgs, ... }:

{
  # Time zone
  time.timeZone = "America/New_York";

  # Locale settings
  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = lib.mkForce "en_GB.UTF-8";  # Using mkForce to override
    };

    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "en_GB.UTF-8/UTF-8"
    ];
  };
}
