{
  description = "Samir's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Add NUR for Firefox extensions
    nur.url = "github:nix-community/NUR";

    btrfs-backup = {
      url = "github:samirparikh/btrfs-backup-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
    home-manager,
    ...
  }: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {

        # Pass all inputs to NixOS modules
        specialArgs = { inherit inputs; };

        modules = [
          ./hosts/nixos

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
            home-manager.extraSpecialArgs = { inherit inputs; };

            home-manager.users.samir = ./home;

            # Automatically backup existing files
            home-manager.backupFileExtension = "backup";
          }
        ];
      };
    };
  };
}
