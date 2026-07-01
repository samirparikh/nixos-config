{ config, pkgs, inputs, pkgs-unstable, ... }:

{
  imports = [
    # Trim or extend this list to taste — modules live under ../programs/.
    ../programs/terminal/fish.nix
    ../programs/terminal/git.nix
    ../programs/terminal/vim
    ../programs/terminal/neovim
    ../programs/terminal/tmux
    ../programs/terminal/starship.nix
    ../programs/direnv.nix

    # Host-specific: catppuccin theme module
    inputs.catppuccin.homeModules.catppuccin
  ];

  home.username = "samir";
  home.homeDirectory = "/home/samir";

  home.packages = (with pkgs; [
    tree
    htop
    claude-code
  ]);

  programs.home-manager.enable = true;

  home.stateVersion = "25.11";
}
