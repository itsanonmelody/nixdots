_:
{
  programs.helix = {
    enable = true;
    ignores = [
      "**/result"
      "**/result/"
    ];
    settings = {
      theme = "nightfox";
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
  };
}
