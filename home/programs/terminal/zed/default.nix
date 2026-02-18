{ config, pkgs, ... }:

{
  programs.zed-editor = {
    enable = true;
    extensions = [ "nix" ];
    userSettings = builtins.fromJSON (builtins.readFile ./settings.json);
  };
}
