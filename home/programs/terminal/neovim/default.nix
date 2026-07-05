{ config, pkgs, inputs, ... }:

let
  # Nix store paths injected as vim globals so init.lua stays portable.
  # On non-NixOS systems, set these globals another way or rely on $PATH.
  #
  # Temporarily stubbed to empty strings: the original references
  # (${pkgs.omnisharp-roslyn}, ${pkgs.netcoredbg}, ${pkgs.fsautocomplete})
  # pull dotnet-vmr-10.0.301 into the closure, which has no binary cache
  # on nixos-unstable and takes hours to build from source. Restore the
  # original interpolations once the multi-host refactor is verified, or
  # once cache.nixos.org publishes the artifacts. See also:
  # home/nixos/default.nix.
  nixPaths = ''
    vim.g.nix_omnisharp_bin   = ""
    vim.g.nix_netcoredbg_bin  = ""
    vim.g.nix_fsautocomplete_bin = ""
  '';
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = with pkgs; [
      # .NET (temporarily disabled — see nixPaths comment above)
      # omnisharp-roslyn
      # netcoredbg
      # csharpier
      # dotnet-sdk_8
      # fsautocomplete

      # General
      ripgrep
      fd
      tree-sitter
      nodejs_22

      # C/C++
      clang-tools
    ];

    plugins = with pkgs.vimPlugins; [
      # Core
      plenary-nvim

      # Theme
      catppuccin-nvim

      # Status line
      lualine-nvim

      # File explorer
      nvim-web-devicons
      nvim-tree-lua

      # Treesitter
      nvim-treesitter.withAllGrammars

      # Telescope
      telescope-fzf-native-nvim
      telescope-nvim

      # Completion
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      luasnip
      cmp_luasnip
      friendly-snippets
      lspkind-nvim
      nvim-cmp

      # Copilot
      copilot-lua
      copilot-cmp

      # F# (Ionide-vim)
      Ionide-vim

      # LSP signature popup
      lsp_signature-nvim

      # Git
      gitsigns-nvim

      # Quality of life
      comment-nvim
      nvim-autopairs
      which-key-nvim
      indent-blankline-nvim

      # DAP (debugging)
      nvim-dap
      nvim-dap-ui
      nvim-nio
    ];

    extraLuaConfig = nixPaths + builtins.readFile ./init.lua;
  };
}
