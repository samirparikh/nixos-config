{ config, pkgs, ... }:

{
  # User account configuration
  users.users.samir = {
    isNormalUser = true;
    description = "samir";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
      # Add user-specific packages here
    ];
  };

  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
}
