{ config, pkgs, ... }:

{
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins;
      [
        vim-airline
        nerdtree
      ];
    settings = { ignorecase = true; };
    # extraConfig = ''
    #   set mouse=a
    # '';
    extraConfig = builtins.readFile ./.vimrc;
  };
}
