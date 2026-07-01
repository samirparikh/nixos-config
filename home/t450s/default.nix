{ config, pkgs, inputs, pkgs-unstable, ... }:

{
  imports = [
    ../programs/terminal/fish.nix
    ../programs/terminal/git.nix
    ../programs/terminal/vim
  ];

  home.username = "samir";
  home.homeDirectory = "/home/samir";

  home.packages = with pkgs; [
    tree
    htop
  ];

  programs.home-manager.enable = true;

  home.stateVersion = "25.11";
}
