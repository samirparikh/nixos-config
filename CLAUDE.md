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

## Open items / next session TODOs

Two open workstreams to pick up in a future session. Kept here (rather than in a separate TODO file) so `CLAUDE.md`'s always-loaded context surfaces them at the start of every session.

### 1. Restore .NET tooling on both hosts

Blocked on `dotnet-vmr-10.0.301` (and 8.0.x, transitively) having no binary cache on the current nixpkgs pin. See the "Temporary: .NET tooling disabled" section above for the full list of packages to un-stub and the exact substitutability check to run.

Sequence when unblocking:
1. Run the `nix-store --realise --dry-run` check above on the current flake pin. If any dotnet-vmr line shows `will be built`, stop — a source build is still required and we're not ready.
2. If everything is `will be fetched`, restore the neovim `nixPaths` interpolations back to `${pkgs.omnisharp-roslyn}/bin/OmniSharp` etc., and uncomment the corresponding `extraPackages` entries in `home/programs/terminal/neovim/default.nix`.
3. In `home/nixos/default.nix`, uncomment `jetbrains.rider`, `dotnet-sdk_10`, `netcoredbg`, `fantomas`.
4. On t450s, the shared neovim module change alone re-enables .NET LSPs there; if you also want the Rider/SDK stack on the laptop, add those packages explicitly to `home/t450s/default.nix` (they were never in the laptop config).
5. Rebuild both hosts.

The 26.05 upgrade below may be what unblocks this — the 26.05 stable cache is likely to have prebuilt dotnet-vmr artifacts that unstable currently lacks.

### 2. Upgrade both hosts to NixOS 26.05

Flake is currently pinned to `nixos-25.11` and `home-manager/release-25.11`. Target 26.05 for both.

Changes required:
- `flake.nix`: bump `nixpkgs.url` to `github:nixos/nixpkgs/nixos-26.05` and `home-manager.url` to `github:nix-community/home-manager/release-26.05`.
- **Do NOT touch `system.stateVersion` on either host.** The value is a first-install pin, not a running-version indicator; upgrading nixpkgs doesn't change it. Same rule for `home.stateVersion`. Both are correct as-is.
- Run `nix flake update` to refresh dependent inputs against the new nixpkgs.
- Verify inputs still work with 26.05: `catppuccin` (rev-pinned, should be fine), `sops-nix`, `nur`, `speedup`.

Verification approach:
1. Build on the desktop first (bigger blast radius): `nix build .#nixosConfigurations.nixos.config.system.build.toplevel` — pure build, no activation. If it succeeds, run the substitutability check to be sure nothing surprising will source-build.
2. If clean, `sudo nixos-rebuild boot --flake .#nixos` and reboot.
3. Then t450s: same sequence, `.#t450s`.

Watch for:
- Modules that changed defaults between 25.11 and 26.05. `stateVersion` gates in module code should preserve old semantics for stateful services, but new modules may add options.
- Any input that lags 26.05 support. Home-manager's `release-26.05` branch always exists but may lag a few days on release day; nixos-26.05 came out May 2026 so this shouldn't matter.
- .NET binary cache status — if fetched, this upgrade doubles as unblocking item 1 above.
