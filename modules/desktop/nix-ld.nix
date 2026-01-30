{ config, pkgs, ... }:

{
  # The C# Dev Kit extension downloads pre-compiled binaries (the Roslyn language server) that are
  # dynamically linked against standard Linux library paths like /lib64/ld-linux-x86-64.so.2.
  # NixOS doesn't have these standard paths, so the binaries fail to execute.
  programs.nix-ld.enable = true;
}
