{ config, pkgs, ... }:

{
  programs.vscode = {
      enable = true;
  
      profiles.default.userSettings = {
          # This property will be used to generate settings.json:
          # https://code.visualstudio.com/docs/getstarted/settings#_settingsjson
          # "editor.formatOnSave" = true;
      };
      # keybindings = [
          # See https://code.visualstudio.com/docs/getstarted/keybindings#_advanced-customization
          # {
              # key = "shift+cmd+j";
              # command = "workbench.action.focusActiveEditorGroup";
              # when = "terminalFocus";
          # }
      # ];
  };

  # The C# Dev Kit extension downloads pre-compiled binaries (the Roslyn language server) that are
  # dynamically linked against standard Linux library paths like /lib64/ld-linux-x86-64.so.2.
  # NixOS doesn't have these standard paths, so the binaries fail to execute.
  programs.nix-ld.enable = true;
}
