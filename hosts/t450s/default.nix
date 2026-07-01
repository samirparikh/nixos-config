{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/networking.nix
    ../../modules/system/security.nix
    ../../modules/system/users.nix
    ../../modules/system/locale.nix
    ../../modules/services/services.nix
    ../../modules/services/dns-resolved.nix
    ../../modules/hardware/audio.nix
    ../../modules/hardware/graphics.nix
    ../../modules/hardware/bluetooth.nix
    ../../modules/desktop/kde.nix
  ];

  networking.hostName = "t450s";

  # Boot loader — legacy BIOS + GRUB in the MBR of /dev/sda.
  # /boot is a vfat partition (Calamares default); GRUB stage 1.5
  # lives in the BIOS boot partition at /dev/sda1.
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.download-buffer-size = 500000000; # 500 MB

  nixpkgs.config.allowUnfree = true;

  # NUR overlay — required so home-manager's firefox.nix can pull
  # extensions from pkgs.nur.repos.rycee.firefox-addons.
  nixpkgs.overlays = [ inputs.nur.overlays.default ];

  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    libimobiledevice
    ifuse
    inputs.speedup.packages.${pkgs.stdenv.hostPlatform.system}.speedup
  ];

  environment.variables.EDITOR = "vim";

  # Nerd Fonts — needed for starship / nvim / tmux icons to render.
  # Konsole must be configured to use one of these as its primary font
  # (Settings → Edit Current Profile → Appearance → Font).
  # https://search.nixos.org/packages?channel=25.11&sort=alpha_asc&query=nerd-fonts
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

  system.stateVersion = "26.05";
}
