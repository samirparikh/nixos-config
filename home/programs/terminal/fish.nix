{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      la = "ls -a";
      home = "cd ~ || exit";
      nixos = "cd /home/samir/nixos-config/ || exit";
    };
  };
}
