{ osConfig, pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    profiles = {
      main = {
        isDefault = true;
        extensions = with pkgs.nur.repos.rycee.firefox-addons;
          [
            bitwarden
            noscript
            ublock-origin
          ];
        settings = {
          extensions.activeThemeID = "firefox-compact-dark@mozilla.org";
        };
        search = {
          default = "Startpage";
          privateDefault = "Startpage";
          engines = {
            "Startpage" = {
              urls = [
                {
                  template = "https://www.startpage.com/sp/search";
                  params = [{ name = "query"; value = "{searchTerms}"; }];
                }
              ];
              iconUpdateURL = "https://www.startpage.com/favicon.ico";
              updateInterval = 24*60*60*1000;
              definedAliases = [ "@st" ];
            };
            "NixOS Wiki" = {
              urls = [{ template = "https://wiki.nixos.org/index.php?search={searchTerms}"; }];
              iconUpdateURL = "https://wiki.nixos.org/favicon.ico";
              updateInterval = 24*60*60*1000;
              definedAliases = [ "@nw" ];
            };
            "NixOS Options" = {
              urls = [
                {
                  template = "https://search.nixos.org/options";
                  params = [
                    { name = "channel"; value = "${osConfig.system.nixos.release}"; }
                    { name = "type"; value = "packages"; }
                    { name = "query"; value = "{searchTerms}"; }
                  ];
                }
              ];

              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@no" ];
            };
            "Nix Packages" = {
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    { name = "channel"; value = "${osConfig.system.nixos.release}"; }
                    { name = "type"; value = "packages"; }
                    { name = "query"; value = "{searchTerms}"; }
                  ];
                }
              ];

              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
            "Bing".metaData.hidden = true;
            "Google".metaData.hidden = true;
            "DuckDuckGo".metaData.hidden = true;
            "Wikipedia (en)".metaData.hidden = true;
          };
        };
      };
    };
  };
}
