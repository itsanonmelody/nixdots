{ local, ... }:
{
  imports = [
    ./programs/shell/zsh
    ./programs/editor/helix
  ];

  home.packages = builtins.concatLists [
    (with local; [
      scripts.touchp
    ])
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
