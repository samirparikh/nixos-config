{ config, pkgs, inputs, ... }:

{
  imports = [
    ./programs/vscode.nix
    ./programs/firefox.nix
    # be sure to also update hosts/nixos/default.nix to
    # include modules/system/virtualization.nix
    # ./programs/virtmanager.nix
    # ./programs/terminal/bash.nix
    ./programs/terminal/fish.nix
    ./programs/terminal/git.nix
    ./programs/terminal/vim
    ./programs/terminal/tmux
    ./programs/terminal/starship.nix

    # Host-specific: catppuccin theme module
    inputs.catppuccin.homeModules.catppuccin
  ];

  home.username = "samir";
  home.homeDirectory = "/home/samir";

  # Packages to install for this user
  home.packages = with pkgs; [
    keepassxc
    kmymoney
    darktable
    free42
    ffmpeg
    libreoffice
    vlc
    chromium
    microsoft-edge
    tree
    freetube
    python3
    dig
    claude-code
    sops
    age
    mullvad-browser
    tor-browser
    pv
    sshfs
    htop
    qbittorrent
    bitwarden-desktop
    haruna
    nodejs_22
    qownnotes
    joplin-desktop
  ];

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with.
  home.stateVersion = "25.05";
}
