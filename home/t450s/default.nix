{ config, pkgs, inputs, pkgs-unstable, ... }:

{
  imports = [
    ../programs/firefox.nix
    ../programs/terminal/fish.nix
    ../programs/terminal/git.nix
    ../programs/terminal/vim
    ../programs/terminal/neovim
    ../programs/terminal/tmux
    ../programs/terminal/starship.nix
    ../programs/direnv.nix

    # Catppuccin theming for fish/nvim/starship/tmux
    inputs.catppuccin.homeModules.catppuccin
  ];

  home.username = "samir";
  home.homeDirectory = "/home/samir";

  home.packages = (with pkgs; [
    tree
    htop
    claude-code
    libreoffice
    free42
    vlc
    ffmpeg
    pv
    sshfs
  ]) ++ (with pkgs-unstable; [
    chromium
    microsoft-edge
    yt-dlp
    darktable
    opencode
  ]);

  programs.home-manager.enable = true;

  home.stateVersion = "25.11";
}
