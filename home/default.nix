{ config, pkgs, ... }:

{
  imports = [
    ./programs/shell.nix
    ./programs/git.nix
    ./programs/vscode.nix
    ./programs/firefox.nix
  ];

  home.username = "samir";
  home.homeDirectory = "/home/samir";

  # Packages to install for this user
  home.packages = with pkgs; [
    vim
    keepassxc
    kmymoney
    darktable
    free42
    ffmpeg
    libreoffice
    vlc
    chromium
    microsoft-edge
  ];

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with.
  home.stateVersion = "25.05";
}
