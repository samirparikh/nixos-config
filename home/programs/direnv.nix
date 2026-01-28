{ config, pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;  # better caching than plain direnv
  };
}
