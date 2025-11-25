{ config, pkgs, ... }:

{
#  programs.bash = {
#    enable = true;
#    
#    shellAliases = {
#      ll = "ls -alh";
#      update = "sudo nixos-rebuild switch --flake ~/.config/nixos#\$(hostname)";
#      upgrade = "sudo nixos-rebuild switch --upgrade --flake ~/.config/nixos#\$(hostname)";
#    };
#
#    bashrcExtra = ''
#      # Custom bash configuration
#      export EDITOR=vim
#    '';
#  };

  programs.fish = {
    enable = true;
  };

  programs.starship = {
    enable = false;
    settings = {
      add_newline = true;
#      character = {
#        success_symbol = "[➜](bold green)";
#        error_symbol = "[➜](bold red)";
#      };
    };
  };
}
