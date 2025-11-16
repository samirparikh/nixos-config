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
}
