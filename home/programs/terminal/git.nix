{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Samir Parikh";
        email = "siparikh@gmail.com";
      };

      init.defaultBranch = "main";
      core.editor = "vim";
      diff.tool = "vimdiff";
      difftool.prompt = false;

      alias = {
        history = "log --all --oneline --decorate";
      };
    };
  };
}
