{ config, pkgs, ... }:

let
  nixPaths = ''
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
      fsautocomplete
      dotnet-sdk_10
      ripgrep
    ];

    plugins = with pkgs.vimPlugins; [
      catppuccin-nvim
      Ionide-vim
      lualine-nvim
      (nvim-treesitter.withPlugins (parsers: [
        parsers.fsharp
        parsers.lua
        parsers.vim
        parsers.vimdoc
        parsers.query
        parsers.nix
        parsers.bash
        parsers.json
        parsers.yaml
        parsers.markdown
        parsers.markdown_inline
      ]))
    ];

    extraLuaConfig = nixPaths + builtins.readFile ./init.lua;
  };
}
