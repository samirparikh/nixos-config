{
  description = "Samir's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Add NUR for Firefox extensions
    nur.url = "github:nix-community/NUR";

    speedup.url = "github:samirparikh/speedup";

    catppuccin = {
      # url = "github:catppuccin/nix";
      url = "github:catppuccin/nix?rev=751b99dca72c7f9df5475c67dcf1059893564e32";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    ...
  }:
  let
    system = "x86_64-linux";
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    mkHost = { hostModule, homeModule }: nixpkgs.lib.nixosSystem {

      # Pass all inputs to NixOS modules
      specialArgs = { inherit inputs pkgs-unstable; };

      modules = [
        hostModule

        ({ config, lib, ... }:
        {
          programs.command-not-found.enable = false;
          programs.nix-index.enable = true;
        })

        # home-manager integration
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          # Pass inputs to home-manager modules
          home-manager.extraSpecialArgs = { inherit inputs pkgs-unstable; };

          home-manager.users.samir = homeModule;

          # Automatically backup existing files
          home-manager.backupFileExtension = "backup";
        }
      ];
    };
  in {
    nixosConfigurations = {
      nixos = mkHost {
        hostModule = ./hosts/nixos;
        homeModule = ./home/nixos;
      };

      t450s = mkHost {
        hostModule = ./hosts/t450s;
        homeModule = ./home/t450s;
      };
    };
  };
}
