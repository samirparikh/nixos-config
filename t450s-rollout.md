# t450s rollout plan

Incremental plan to layer functionality back onto the stripped-down t450s
config after a fresh install. Each step is one commit and one rebuild;
verify before moving on. If a step breaks, roll back to the previous
generation (see "Rollback" section below) and diagnose the delta.

## Context for a cold reader (Claude or human)

- The t450s laptop had a Calamares graphical install of NixOS 26.05,
  legacy BIOS, single ext4 partition, no LUKS. First flake build after
  install kernel-panicked and left the MBR unbootable, forcing a
  reinstall. In response, the t450s config was stripped to a bare
  bootable-and-networked baseline (commit `3938940`), which succeeded.
- We are now layering functionality back on, one commit / one rebuild
  at a time, so any regression is bisected to a single small change.
- The **desktop (`nixos` host) config is unchanged** through this whole
  process. All edits are to `hosts/t450s/default.nix` and
  `home/t450s/default.nix`. The shared modules under `modules/` and
  `home/programs/` are untouched.
- Working branch: `addhost` (not yet merged to `main`). Push from
  desktop, pull on laptop, rebuild.

## Progress

- [x] **Step 0 — MVP baseline** (commit `3938940`)
  - Bootable text-console system. Ethernet/wifi via NetworkManager.
  - Verified: tty1 login as `samir`, `nmcli` works, `ping` succeeds.

- [x] **Step 1 — KDE + audio + graphics + bluetooth** (commit `df2f52d`)
  - Added imports: `audio.nix`, `graphics.nix`, `bluetooth.nix`, `kde.nix`.
  - Verified on laptop: SDDM appears after reboot, Plasma 6 desktop
    up, `bluetoothctl` sees the controller. Audio CLI test skipped
    (`speaker-test` and browser both unavailable in this MVP — pipewire
    is running though, so audio should work once `alsa-utils` or a
    browser is installed).

- [x] **Step 2 — security.nix** (commit `d4571bd`) — verified on laptop
  - Edit `hosts/t450s/default.nix` imports, add:
    ```nix
    ../../modules/system/security.nix
    ```
  - What it turns on: `sudo` wheel-with-password (already default),
    polkit, rtkit (real-time scheduling for pipewire), and the
    vaultwarden CA cert at `certs/vaultwarden.crt`.
  - Verify:
    - `sudo -v` still prompts once and works
    - `pactl info` shows pipewire; audio latency subjectively better
    - `curl https://<vaultwarden-url>` succeeds (or `openssl s_client`
      shows the cert as trusted)

- [x] **Step 3 — services.nix (tailscale, mullvad, usbmuxd)** (commit `ed76444`) — verified on laptop
  - Edit `hosts/t450s/default.nix` imports, add:
    ```nix
    ../../modules/services/services.nix
    ```
  - Verify:
    - `sudo tailscale up` → then `tailscale status` shows tailnet
    - `mullvad status` responds (installer runs on first login)
    - Plug in iPhone → `ifuse` mounts (uses usbmuxd)

- [x] **Step 4 — Extended home dev environment** (commit `c84c6ac`) — verified on laptop (starship/nvim/tmux/direnv/catppuccin all working; icons required a Nerd Font, handled in step 5)
  - Edit `home/t450s/default.nix` imports, add:
    ```nix
    ../programs/terminal/neovim
    ../programs/terminal/tmux
    ../programs/terminal/starship.nix
    ../programs/direnv.nix
    inputs.catppuccin.homeModules.catppuccin
    ```
  - Add packages to `home.packages`: `pandoc`, `claude-code` (already
    in the MVP), maybe `sops`/`age` if you plan to use secrets here.
  - **Watch for source-build trap:** the shared `neovim/default.nix`
    module currently has its .NET tooling commented out (see
    `CLAUDE.md`). Do **not** un-stub it unless
    `nix-store --realise --dry-run $(nix eval --raw .#nixosConfigurations.t450s.config.system.build.toplevel.drvPath)`
    reports zero `will be built` lines for dotnet-vmr.
  - Verify:
    - `nvim` opens, LSPs load for at least one file type
    - `tmux new` works; starship prompt renders in fish
    - `direnv` hook fires when entering a `.envrc` dir
    - Catppuccin theme applied in fish/nvim/starship

- [~] **Step 5 — Optional extras (cleanup pass)** — in progress
  - [x] Nerd Fonts (`fira-code`, `meslo-lg`, `symbols-only`) — commit `5172ae7`
        (fixed missing starship glyphs; Konsole profile pointed at
        FiraCode Nerd Font manually)
  - [x] `libimobiledevice`, `ifuse` in `environment.systemPackages`
  - [ ] `nix-ld` module (`modules/desktop/nix-ld.nix`) — only if you
    actually run dynamically linked binaries outside nixpkgs
  - [x] `NUR` overlay + Firefox with declarative extensions (ublock-origin,
        web-archives, vimium, sponsorblock)
  - [x] `speedup` package (from personal flake input)
  - [ ] Rest of the Nerd Fonts (expand beyond the three added above)

- [ ] **Step 6 — Merge to `main`**
  - Once the laptop matches the desired steady state, open a PR from
    `addhost` → `main` on GitHub.
  - Pull on the desktop, `nixos-rebuild switch --flake .#nixos`, verify
    nothing regressed there.

## Rebuild procedure (per step)

On the desktop (where edits are made):

```bash
# edit, commit, push
git push
```

On the laptop:

```bash
git pull
sudo nixos-rebuild switch --flake .#t450s
```

- Use `switch`, not `boot` — the bootloader is already NixOS-owned,
  and `switch` activates immediately so you see the effect.
- No `--install-bootloader` needed after step 1's initial takeover.
- `NIX_CONFIG='experimental-features = …'` prefix is no longer needed
  since `nix.settings.experimental-features` is in the flake config.
- Skim the eval output for `will be built` lines. If anything
  non-trivial appears (dotnet-vmr, large from-source builds), stop
  and check `cache.nixos.org` substitutability before proceeding.

## Rollback (per step)

If activation succeeds but reveals a regression:

```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
# Activate the previous known-good one (N-1) live
sudo /nix/var/nix/profiles/system-<N-1>-link/bin/switch-to-configuration switch
```

If activation fails hard or the machine won't boot:

- Reboot → GRUB menu → "NixOS — all configurations" → pick the older
  generation. That should always be reachable now that the MBR is
  NixOS-managed.

If the flake won't even evaluate (eval error), fix the .nix file and
retry. You never activate a broken generation, so no rollback needed.

## Known gotchas / decisions carried over

- **`system.stateVersion = "26.05"`** in `hosts/t450s/default.nix` —
  set to match the 26.05 installer; do not bump when the flake later
  moves nixpkgs to 26.11 or later. It's a first-install pin, not a
  running-version indicator.
- **`home.stateVersion = "25.11"`** in `home/t450s/default.nix` —
  matches the pinned home-manager (`release-25.11`). Also
  never-bump-again.
- **Boot config is inlined**, not shared with the desktop. The desktop
  uses `modules/system/boot.nix` (UEFI + systemd-boot). The laptop's
  legacy BIOS + GRUB block lives directly in `hosts/t450s/default.nix`.
  Don't re-import the shared boot module on t450s.
- **`sops-nix` and secrets are disabled** on t450s. If you eventually
  want secrets on the laptop, uncomment the `sops-nix` module import
  and the `sops = { … }` config block together, and provision the age
  key at `~/.config/sops/age/keys.txt`.
- **`btrfs-subvolumes.nix` is not imported** on t450s and shouldn't be
  — the module is hardcoded to the desktop's btrfs UUID and its
  systemd.tmpfiles rules create `~/Desktop`, `~/Documents`, etc.
  directories that the laptop doesn't need.
- **`dns.nix` is not imported** on t450s — it pins the LAN AdGuard box
  (`192.168.1.229`) and installs a firewall that would break DNS on
  any non-home network.

## Cleanup when done

Once the laptop is in its target state and merged to `main`, this
file can be deleted or replaced with a brief `docs/t450s-notes.md`
capturing only the durable decisions (BIOS/GRUB, no-encryption
choice, no-sops choice).
