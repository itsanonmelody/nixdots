{ config, osConfig, pkgs, ... }:
let
  hasPackages = packages:
    builtins.any (pkg: builtins.elem pkg config.home.packages) packages;
in
{
  programs.firefox = {
    enable = true;
    profiles = {
      main = {
        isDefault = true;
        extensions = with pkgs.nur.repos.rycee.firefox-addons;
          builtins.concatLists [
            [
              noscript
              ublock-origin
            ]
            (if (hasPackages (with pkgs;
                  [
                    bitwarden-cli
                    bitwarden-desktop
                  ]))
              then [ bitwarden ] else [ ])
          ];
        settings = {
          extensions.activeThemeID = "firefox-compact-dark@mozilla.org";
          browser.newtabpage.activity-stream = {
            showSponsored = false;
            showSponsoredTopSites = false;
            system.showSponsored = false;
          };
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
            "MyNixOS Options" = {
              urls = [
                {
                  template = "https://mynixos.com/search";
                  params = [{ name = "q"; value = "{searchTerms}"; }];
                }
              ];
              icon = "https://mynixos.com/favicon.ico";
              updateInterval = 24*60*60*1000;
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
