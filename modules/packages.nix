{ config, pkgs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Firefox
  programs.firefox.enable = true;

  # System-wide packages
  environment.systemPackages = with pkgs; [
    # vim
    # wget
    # git
    libimobiledevice
    ifuse
  ];

  # Default editor
  # environment.variables.EDITOR = "vim";

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.download-buffer-size = 500000000; # 500 MB
}
