# NixOS Configuration - nixos

This is a modular NixOS configuration using flakes and home-manager.

## Structure

- `flake.nix` - Main flake configuration
- `hosts/` - Host-specific configurations
- `modules/` - Reusable system modules
  - `system/` - Core system configuration
  - `hardware/` - Hardware-specific settings
  - `services/` - Service configurations
  - `desktop/` - Desktop environment modules
- `home/` - Home Manager configuration

nixos-config/
├── flake.nix
├── hosts/
│   ├── hostname1/
│   │   ├── default.nix          # Host-specific configuration
│   │   └── hardware-configuration.nix
│   └── hostname2/
│       ├── default.nix
│       └── hardware-configuration.nix
├── modules/
│   ├── system/                   # System-level modules
│   │   ├── boot.nix
│   │   ├── networking.nix
│   │   ├── security.nix
│   │   ├── users.nix
│   │   └── virtualisation.nix
│   ├── hardware/                 # Hardware-specific modules
│   │   ├── audio.nix
│   │   ├── bluetooth.nix
│   │   └── graphics.nix
│   ├── services/                 # Service configurations
│   │   ├── ssh.nix
│   │   ├── docker.nix
│   │   └── vpn.nix
│   └── desktop/                  # Desktop environment modules
│       ├── gnome.nix
│       ├── kde.nix
│       └── xserver.nix
├── home/
│   ├── profiles/
│   │   ├── default.nix
│   │   ├── development.nix
│   │   └── minimal.nix
│   └── programs/                 # Per-program home-manager configs
│       ├── git.nix
│       ├── shell.nix
│       └── editor.nix
└── overlays/                     # Package overlays
    └── default.nix

## Usage

### First-time setup

1. Review and customize the configuration files
2. Update `hosts/nixos/hardware-configuration.nix` with your hardware details:
   ```bash
   sudo cp /etc/nixos/hardware-configuration.nix hosts/nixos/
   ```
3. Adjust settings in `hosts/nixos/default.nix`

### Building the configuration

```bash
# Build and switch to the new configuration
sudo nixos-rebuild switch --flake .#nixos

# Test without switching
sudo nixos-rebuild test --flake .#nixos

# Update flake inputs
nix flake update
```

## Customization

### Enable/Disable Features

Edit `hosts/nixos/default.nix` and toggle the options:

```nix
mySystem.services.docker.enable = true;
mySystem.desktop.gnome.enable = true;
```

### Add New Modules

1. Create a new module file in the appropriate `modules/` subdirectory
2. Import it in your host configuration
3. Use `mkEnableOption` for toggleable features

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
