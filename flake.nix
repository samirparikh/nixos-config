{
  description = "Samir's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
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
  };

  outputs = inputs@{
    nixpkgs,
    home-manager,
    nur,
    btrfs-backup,
    catppuccin,
    ...
  }: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {

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
            home-manager.users.samir = {
              imports = [
                ./home
                catppuccin.homeModules.catppuccin
              ];
            };

            # Automatically backup existing files
            home-manager.backupFileExtension = "backup";

            # Make NUR available in home-manager
            nixpkgs.overlays = [ nur.overlays.default ];
          }

          # Your backup script flake module
          btrfs-backup.nixosModules.default
        ];
      };
    };
  };
}
