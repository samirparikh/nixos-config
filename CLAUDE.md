# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

```bash
# Apply configuration changes (replace `nixos` with `t450s` on the laptop)
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

This is a NixOS flake config for multiple hosts (x86_64-linux). Current hosts: `nixos` (desktop) and `t450s` (ThinkPad laptop, stub — `hardware-configuration.nix` to be generated at install time). It uses:
- **nixpkgs 25.11** as the stable channel
- **nixpkgs-unstable** exposed as `pkgs-unstable` for packages that need frequent updates (yt-dlp, freetube, opencode, chromium, etc.)
- **home-manager** (release-25.11) integrated as a NixOS module, managing the `samir` user
- **sops-nix** for secrets, encrypted with age at `~/.config/sops/age/keys.txt`
- **catppuccin** theme module applied via home-manager

### Module wiring

`flake.nix` defines a `mkHost { hostModule, homeModule }` helper that composes:
- `hostModule` → `hosts/<host>/default.nix` (system config)
- `homeModule` → `home/<host>/default.nix` (user/home-manager config)

Each host picks its own subset of `home/programs/*` imports, so the two hosts share the program modules but not the package list. `home/programs/` (shared) and `modules/` (shared system/hardware/services/desktop) are the reusable pieces.

`specialArgs` passes `inputs` and `pkgs-unstable` to both NixOS modules and home-manager modules, so any module can access either.

### Coupled toggles

Virtualization (`libvirt`/`virt-manager`) requires enabling **both**:
- `../../modules/system/virtualization.nix` in `hosts/<host>/default.nix`
- `../programs/virtmanager.nix` in `home/<host>/default.nix`

Comments in both files flag this dependency.

### Secrets

Secrets are encrypted YAML files under `secrets/` using age key pinned in `.sops.yaml`. The sops module is imported in `hosts/nixos/default.nix` and secrets are declared there. Secret paths are accessed at runtime via `config.sops.secrets.<name>.path`. Never add plaintext values to any `.nix` file.

### Backup

`modules/services/btrbk.nix` defines two btrbk instances (daily/weekly) that snapshot btrfs subvolumes under `/mnt/btrfs-root` and push them to remote host `blbu` over SSH as root using key `/root/.ssh/btrbk_ed25519`. A wrapper script at `/etc/btrbk/btrbk-notify.sh` sends ntfy notifications around each run.

### Temporary: .NET tooling disabled

The following .NET-touching packages are commented out to avoid building `dotnet-vmr-10.0.301` (and `10.0.9` transitively) from source, which has no binary cache on nixos-unstable and takes hours:

- `home/nixos/default.nix` (in `home.packages`):
  - `jetbrains.rider` — wraps `dotnet-sdk-10.0.301`, the actual root cause; verified via `nix why-depends`
  - `dotnet-sdk_10`, `netcoredbg`, `fantomas`
- `home/programs/terminal/neovim/default.nix` (in `extraPackages`):
  - `omnisharp-roslyn`, `netcoredbg`, `csharpier`, `dotnet-sdk_8`, `fsautocomplete`
  - The corresponding `vim.g.nix_*_bin` interpolations in the `nixPaths` let-binding are also stubbed to empty strings (otherwise the `${pkgs.X}` references keep those derivations in the closure even when not in `extraPackages`)

**To restore:** uncomment the lines in both files and revert the `nixPaths` block in the neovim module back to its `${pkgs.X}/bin/Y` interpolations. Plan to do this after the multi-host refactor is verified end-to-end, ideally when `cache.nixos.org` has prebuilt the dotnet artifacts. Check substitutability with:

```bash
nix-store --realise --dry-run $(nix eval --raw .#nixosConfigurations.nixos.config.system.build.toplevel.drvPath)
```

If the output says "will be built", a source build is still required. If it says "will be fetched", the cache has it.
