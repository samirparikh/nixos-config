# NixOS Configuration

This is a modular NixOS configuration using flakes, home-manager, and sops-nix for secrets management.

## Structure

```
nixos-config/
├── flake.nix                      # Main flake configuration with inputs
├── flake.lock                     # Locked flake dependencies
├── .sops.yaml                     # SOPS configuration for secret encryption
├── secrets/                       # Encrypted secrets (YAML files)
│   ├── nextdns.yaml
│   └── search-domain.yaml
├── hosts/
│   └── nixos/                     # Host-specific configuration
│       ├── default.nix            # Main host config, imports modules
│       ├── hardware-configuration.nix  # Hardware-specific settings
│       └── filesystems-home.nix   # Filesystem configuration
├── modules/
│   ├── system/                    # System-level modules
│   │   ├── boot.nix               # Boot loader and kernel settings
│   │   ├── networking.nix         # Network configuration
│   │   ├── security.nix           # Security settings
│   │   ├── users.nix              # User account management
│   │   ├── locale.nix             # Locale and timezone settings
│   │   ├── btrfs-subvolumes.nix   # Btrfs subvolume management
│   │   └── virtualization.nix     # VM/container configuration
│   ├── hardware/                  # Hardware-specific modules
│   │   ├── audio.nix              # Audio configuration
│   │   ├── bluetooth.nix          # Bluetooth settings
│   │   └── graphics.nix           # GPU and graphics settings
│   ├── services/                  # Service configurations
│   │   ├── services.nix           # General services
│   │   ├── backup.nix             # Backup configuration
│   │   └── dns.nix                # DNS and NextDNS configuration
│   └── desktop/                   # Desktop environment modules
│       └── kde.nix                # KDE Plasma configuration
└── home/
    ├── default.nix                # Main home-manager configuration
    └── programs/                  # Per-program home-manager configs
        ├── terminal/              # Terminal-related programs
        │   ├── bash.nix
        │   ├── fish.nix
        │   ├── git.nix
        │   ├── starship.nix
        │   ├── tmux/
        │   └── vim/
        ├── firefox.nix            # Firefox configuration with extensions
        ├── vscode.nix             # VS Code configuration
        └── virtmanager.nix        # Virtual Machine Manager
```

### Flake Inputs

This configuration uses the following flake inputs:
- **nixpkgs** - NixOS package collection (25.11)
- **home-manager** - User environment management
- **nur** - Nix User Repository (for Firefox extensions)
- **btrfs-backup** - Custom btrfs backup solution
- **speedup** - Custom package
- **catppuccin** - Catppuccin theming
- **sops-nix** - Secret management with SOPS

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

## SOPS Encryption for Secrets

This configuration uses [sops-nix](https://github.com/Mic92/sops-nix) to securely manage secrets using age encryption.

### Initial Setup

1. **Generate an age key** (if you don't have one):
   ```bash
   mkdir -p ~/.config/sops/age
   age-keygen -o ~/.config/sops/age/keys.txt
   ```

2. **Get your public key**:
   ```bash
   age-keygen -y ~/.config/sops/age/keys.txt
   ```
   This will output something like: `age1vg35exts78hl2j753r8dr48y36pk729ds37yj7mt6hxg3dvesctsacux0p`

3. **Update `.sops.yaml`** with your public key:
   ```yaml
   keys:
     - &nixos age1vg35exts78hl2j753r8dr48y36pk729ds37yj7mt6hxg3dvesctsacux0p

   creation_rules:
     - path_regex: secrets/.*\.yaml$
       key_groups:
         - age:
             - *nixos
   ```

### Creating and Encrypting Secrets

1. **Create a new secret file**:
   ```bash
   # Create the secrets directory if it doesn't exist
   mkdir -p secrets

   # Create and edit a new encrypted secret
   sops secrets/my-secret.yaml
   ```

2. **Edit the secret** in your editor (SOPS will decrypt it automatically):
   To edit the file:
   ```
   sops secretsfile.yaml
   ```
   To view the secret:
   ```
   sops -d secretsfile.yaml

   # Example secret structure
   my_api_key: sk-1234567890abcdef
   database_password: super-secret-password
   ```

   When you save and exit, SOPS will automatically encrypt the file.

3. **Verify the secret is encrypted**:
   ```bash
   cat secrets/my-secret.yaml
   ```
   You should see encrypted content with SOPS metadata.

### Using Secrets in NixOS Configuration

1. **Import sops-nix module** in `hosts/nixos/default.nix`:
   ```nix
   imports = [
     inputs.sops-nix.nixosModules.sops
     # ... other imports
   ];
   ```

2. **Configure SOPS** in your host configuration:
   ```nix
   sops = {
     defaultSopsFile = ../../secrets/my-secret.yaml;
     age.keyFile = "/home/samir/.config/sops/age/keys.txt";

     # Define secrets to be made available
     secrets.my_api_key = {};
     secrets.database_password = {
       sopsFile = ../../secrets/other-secret.yaml;  # Optional: use different file
     };
   };
   ```

3. **Reference secrets in your configuration**:
   ```nix
   # The decrypted secret will be available at runtime
   services.myservice = {
     enable = true;
     apiKeyFile = config.sops.secrets.my_api_key.path;
   };
   ```

### Modifying Existing Secrets

1. **Edit an encrypted secret**:
   ```bash
   sops secrets/my-secret.yaml
   ```
   SOPS will decrypt the file, open your editor, and re-encrypt on save.

2. **Add a new key to an existing secret**:
   Just edit the file with `sops` and add the new key-value pair.

3. **Rotate encryption keys**:
   ```bash
   # Update .sops.yaml with new public key
   # Then re-encrypt all secrets
   sops updatekeys secrets/my-secret.yaml
   ```

### Example: Current Configuration

This configuration uses SOPS for:
- **NextDNS configuration** (`secrets/nextdns.yaml`) - Referenced in `modules/services/dns.nix:10`
- **Search domain** (`secrets/search-domain.yaml`) - Used in `modules/services/dns.nix:83`

Both secrets are configured in `hosts/nixos/default.nix:96-104` and accessed via:
```nix
config.sops.secrets.nextdns_config.path
config.sops.secrets.search_domain.path
```

### Important Notes

- **Never commit unencrypted secrets** to git
- The `.sops.yaml` file and encrypted secret files in `secrets/` are safe to commit
- The private key (`~/.config/sops/age/keys.txt`) must **never** be committed
- Each secret file is encrypted with the public keys defined in `.sops.yaml`
- Secrets are decrypted at activation time and made available to services

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [sops-nix Documentation](https://github.com/Mic92/sops-nix)
