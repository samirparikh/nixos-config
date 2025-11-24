{
  description = "Samir's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Add NUR for Firefox extensions
    nur.url = "github:nix-community/NUR";

    btrfs-backup = {
      # Option 1: Local path during development
      url = "/home/samir/flakes/btrfs-backup-flake";
      # Option 2: From GitHub (once pushed)
      # url = "github:yourusername/btrfs-backup-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, nur, btrfs-backup, ... }: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/nixos

          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.samir = import ./home;
            
            # Automatically backup existing files
            home-manager.backupFileExtension = "backup";

            # Make NUR available in home-manager
            nixpkgs.overlays = [ nur.overlays.default ];
          }

          btrfs-backup.nixosModules.default

        ];
      };
    };
  };
}
