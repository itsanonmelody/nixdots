_:
{
  imports = [
    ./programs/shell/zsh
    ./programs/editor/helix
  ];

  xdg = {
    enable = true;
    userDirs = {
      enable = false;
      createDirectories = false;
    };
  };

  home.stateVersion = "24.05";
}
