{ config, pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    profiles.samir = {
      extensions = {
        packages = with pkgs.nur.repos.rycee.firefox-addons; [
          # Add your extensions here. Some popular ones:
          ublock-origin
          tree-style-tab
          web-archives
          vimium
          # You can find more at: https://nur.nix-community.org/repos/rycee/
        ];
      };
      
      settings = {
        # Optional: Firefox settings
        "browser.startup.homepage" = "https://nixos.org";
        "browser.search.defaultenginename" = "DuckDuckGo";

        # Additional settings to ensure extensions work
        # "extensions.autoDisableScopes" = 0;
        # "extensions.enabledScopes" = 15;
        
        # Required to enable userChrome.css
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
      
      # Add userChrome.css
      userChrome = ''
        /* hides the native tabs */
        #tabbrowser-tabs {
          visibility: collapse !important;
        }
      '';
    };
  };
}
