{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      la = "ls -a";
      home = "cd ~ || exit";
      nixos = "cd /home/samir/nixos-config/ || exit";
      cses = "cd /home/samir/Documents/programming/clang/cses2/ || exit";
    };
    shellAbbrs = {
      gcc = "gcc -std=c23 -O2 -Wall -Wextra -Wpedantic -Werror";
      clang = "clang -std=c23 -O2 -Wall -Wextra -Wpedantic -Werror";
    };
  };
}
