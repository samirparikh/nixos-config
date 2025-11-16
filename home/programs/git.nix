{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Samir Parikh";
    userEmail = "siparikh@gmail.com";
    
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "vim";
      diff.tool = "vimdiff";
      difftool.prompt = false;
    };

    aliases = {
      history = "log --all --oneline --decorate";
      # st = "status";
      # co = "checkout";
      # br = "branch";
      # ci = "commit";
      # unstage = "reset HEAD --";
    };
  };
}
