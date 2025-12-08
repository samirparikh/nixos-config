{ config, pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    profiles.samir = {
      extensions = {
        packages = with pkgs.nur.repos.rycee.firefox-addons; [
          # Add your extensions here. Some popular ones:
          ublock-origin
          # tree-style-tab
          web-archives
          vimium
          sponsorblock
          # You can find more at: https://nur.nix-community.org/repos/rycee/
        ];
      };
      
      settings = {
        # Optional: Firefox settings
        # see this page for more options on setting and policies:
        # https://github.com/Kreyren/nixos-config/blob/central/src/nixos/users/kreyren/home/modules/web-browsers/firefox/firefox.nix

        # Disable browser password manager
        "browser.contextual-password-manager.enabled" = false;

        # Disable sponsored suggestions on new tab pages
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.system.showSponsored" = false;
        "browser.newtabpage.activity-stream.system.showSponsoredCheckboxes" = false;
        "browser.newtabpage.sponsor-protection.enabled" = false;

        # Set default search engine
        "browser.search.defaultenginename" = "Google";

        # Define browser startup behavior
        "browser.sessionstore.restore_on_demand" = true;
        "browser.sessionstore.resume_from_crash" = true;
        "browser.startup.page" = 3;
        "browser.startup.homepage" = "https://nixos.org";

        # Additional settings to ensure extensions work
        # "extensions.autoDisableScopes" = 0;
        # "extensions.enabledScopes" = 15;

        # Browser layout
        "sidebar.verticalTabs" = true;
        
        # Required to enable userChrome.css
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
      
      # Add userChrome.css
#      userChrome = ''
#        /* hides the native tabs */
#        #tabbrowser-tabs {
#          visibility: collapse !important;
#        }
#      '';
    };
  };
}
