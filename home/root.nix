{ local, ... }:
{
  imports = [
    ./themes/root
    ./programs/editor/helix
    ./programs/editor/neovim
    ./programs/multiplexer/zellij
    ./programs/shell/zsh
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

  home.stateVersion = "24.11";
}
