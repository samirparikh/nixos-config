{ config, pkgs, inputs, pkgs-unstable, ... }:

{
  imports = [
    ../programs/vscode.nix
    ../programs/firefox.nix
    # be sure to also update hosts/nixos/default.nix to
    # include modules/system/virtualization.nix
    # ../programs/virtmanager.nix
    # ../programs/terminal/bash.nix
    ../programs/terminal/fish.nix
    ../programs/terminal/git.nix
    ../programs/terminal/vim
    ../programs/terminal/neovim
    ../programs/terminal/tmux
    ../programs/terminal/starship.nix
    ../programs/direnv.nix
    ../programs/terminal/zed

    # Host-specific: catppuccin theme module
    inputs.catppuccin.homeModules.catppuccin
  ];

  home.username = "samir";
  home.homeDirectory = "/home/samir";

  # Packages to install for this user
  home.packages = (with pkgs; [
    keepassxc
    kmymoney
    free42
    ffmpeg
    libreoffice
    vlc
    tree
    python3
    dig
    sops
    age
    tor-browser
    pv
    sshfs
    htop
    qbittorrent
    nodejs_22
    kdePackages.kclock
    weechat
    exercism
    jetbrains.rider
    dotnet-sdk_10
    netcoredbg
    fantomas
    pandoc
    claude-code
  ]) ++ (with pkgs-unstable; [
    opencode         # same
    yt-dlp           # updates constantly (site breakage fixes)
    freetube         # tracks YouTube API changes
    darktable
    chromium
    microsoft-edge
  ]);

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with.
  home.stateVersion = "25.05";
}
