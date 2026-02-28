{ config, pkgs, inputs, ... }:

let
  # Nix store paths injected as vim globals so init.lua stays portable.
  # On non-NixOS systems, set these globals another way or rely on $PATH.
  nixPaths = ''
    vim.g.nix_omnisharp_bin   = "${pkgs.omnisharp-roslyn}/bin/OmniSharp"
    vim.g.nix_netcoredbg_bin  = "${pkgs.netcoredbg}/bin/netcoredbg"
    vim.g.nix_fsautocomplete_bin = "${pkgs.fsautocomplete}/bin/fsautocomplete"
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
      # .NET
      omnisharp-roslyn
      netcoredbg
      csharpier
      dotnet-sdk_8
      fsautocomplete

      # General
      ripgrep
      fd
      tree-sitter
      nodejs_22
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
