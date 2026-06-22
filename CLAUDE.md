# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

```bash
# Apply configuration changes
sudo nixos-rebuild switch --flake .#nixos

# Test a build without switching
sudo nixos-rebuild test --flake .#nixos

# Update all flake inputs
nix flake update

# Update a single input
nix flake update nixpkgs

# Edit / create an encrypted secret
sops secrets/my-secret.yaml

# View a decrypted secret
sops -d secrets/my-secret.yaml

# btrbk: dry-run to preview backup changes
sudo btrbk -c /etc/btrbk/daily.conf dryrun
sudo btrbk -c /etc/btrbk/weekly.conf dryrun

# Check backup timer status
systemctl list-timers 'btrbk-*'
```

## Architecture

This is a NixOS flake config for a single host (`nixos`, x86_64-linux). It uses:
- **nixpkgs 25.11** as the stable channel
- **nixpkgs-unstable** exposed as `pkgs-unstable` for packages that need frequent updates (yt-dlp, freetube, opencode, chromium, etc.)
- **home-manager** (release-25.11) integrated as a NixOS module, managing the `samir` user
- **sops-nix** for secrets, encrypted with age at `~/.config/sops/age/keys.txt`
- **catppuccin** theme module applied via home-manager

### Module wiring

`flake.nix` → `hosts/nixos/default.nix` (system) + `home/default.nix` (user).

All reusable system config lives under `modules/` (system, hardware, services, desktop). All user config lives under `home/programs/`.

`specialArgs` passes `inputs` and `pkgs-unstable` to both NixOS modules and home-manager modules, so any module can access either.

### Coupled toggles

Virtualization (`libvirt`/`virt-manager`) requires enabling **both**:
- `../../modules/system/virtualization.nix` in `hosts/nixos/default.nix`
- `./programs/virtmanager.nix` in `home/default.nix`

Comments in both files flag this dependency.

### Secrets

Secrets are encrypted YAML files under `secrets/` using age key pinned in `.sops.yaml`. The sops module is imported in `hosts/nixos/default.nix` and secrets are declared there. Secret paths are accessed at runtime via `config.sops.secrets.<name>.path`. Never add plaintext values to any `.nix` file.

### Backup

`modules/services/btrbk.nix` defines two btrbk instances (daily/weekly) that snapshot btrfs subvolumes under `/mnt/btrfs-root` and push them to remote host `blbu` over SSH as root using key `/root/.ssh/btrbk_ed25519`. A wrapper script at `/etc/btrbk/btrbk-notify.sh` sends ntfy notifications around each run.
