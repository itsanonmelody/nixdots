_:
{
  programs.thunderbird = {
    enable = true;
    settings = {
      "extensions.activeThemeID" = "thunderbird-compact-dark@mozilla.org";
      "mailnews.default_sort_type" = "18";
      "mailnews.default_sort_order" = "2";
      "mailnews.default_sort_view" = "1";
    };
    profiles = {
      "main" = {
        isDefault = true;
        settings = {
          "intl.locale.requested" = "de,en-US";
        };
      };
    };
  };
}
