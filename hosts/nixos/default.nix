{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # ./filesystems-home.nix
    ../../modules/system/boot.nix
    ../../modules/system/networking.nix
    ../../modules/system/security.nix
    ../../modules/system/users.nix
    ../../modules/system/locale.nix
    ../../modules/services/services.nix
    ../../modules/hardware/audio.nix
    ../../modules/hardware/graphics.nix
    ../../modules/hardware/bluetooth.nix
    ../../modules/desktop/kde.nix
  ];

  # Hostname
  networking.hostName = "nixos";

  # Increase download buffer size
  nix.settings.download-buffer-size = 500000000; # 500 MB

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Feature toggles
  # mySystem.desktop.kde.enable = true;
  # mySystem.hardware.bluetooth.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Firefox
  # programs.firefox.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    # vim
    wget
    curl
    git
    # htop
    libimobiledevice
    ifuse
  ];

  # Install Nerd Fonts
  # find more here
  # https://search.nixos.org/packages?channel=25.05&sort=alpha_asc&query=nerd-fonts.
  fonts.packages = with pkgs.nerd-fonts; [
    adwaita-mono
    agave
    blex-mono
    caskaydia-cove
    caskaydia-mono
    droid-sans-mono
    fira-code
    fira-mono
    geist-mono
    go-mono
    inconsolata
    inconsolata-go
    inconsolata-lgc
    intone-mono
    lilex
    meslo-lg
    monaspace
    mononoki
    noto
    overpass
    recursive-mono
    roboto-mono
    symbols-only
    tinos
  ];

  # Default editor
  # environment.variables.EDITOR = "vim";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = "25.05";
}
