{ lib, ... }:
with lib;
{
  programs.helix = {
    enable = true;
    ignores = [
      "**/result"
      "**/result/"
    ];
    settings = {
      theme = mkDefault "nightfox";
      editor = {
        line-number = "relative";
        file-picker = {
          hidden = false;
        };
        indent-guides = {
          render = true;
        };
      };
    };
    languages = {
      language = [
        {
          name = "c";
          indent = {
            tab-width = 4;
            unit = "    ";
          };
        }
        {
          name = "rust";
          auto-format = false;
        }
      ];
    };
  };
}
