{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
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
  ];

  environment.variables.EDITOR = "vim";

  # Nerd Fonts — needed for starship / nvim / tmux icons to render.
  # Konsole must be configured to use one of these as its primary font
  # (Settings → Edit Current Profile → Appearance → Font).
  fonts.packages = with pkgs.nerd-fonts; [
    fira-code
    meslo-lg
    symbols-only
  ];

  system.stateVersion = "26.05";
}
