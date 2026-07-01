{ config, pkgs, inputs, pkgs-unstable, ... }:

{
  imports = [
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

  home.packages = with pkgs; [
    tree
    htop
    claude-code
  ];

  programs.home-manager.enable = true;

  home.stateVersion = "25.11";
}
