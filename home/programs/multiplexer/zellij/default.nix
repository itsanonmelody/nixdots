{ config, lib, pkgs, ... }:
let
  inherit (lib) getExe mkIf mkOrder;

  cfg = config.programs.zellij;
  zellijCmd = getExe cfg.package;

  packages = config.home.packages;
  hasBash = builtins.elem pkgs.bash packages;
  hasFish = builtins.elem pkgs.fish packages;
  hasZsh = builtins.elem pkgs.zsh packages;
in
{
  programs.zellij = {
    enable = true;
    settings = {
      on_force_close = "quit";
    };
  };

  programs.bash.initExtra = mkIf hasBash
    (mkOrder 200 ''
      if [ -z "$SUDO_USER" ];
      then
        eval "$(${zellijCmd} setup --generate-auto-start bash)"
      fi
    '');

  programs.fish.interactiveShellInit = mkIf hasFish
    (mkOrder 200 ''
      if test -z $SUDO_USER
        eval (${zellijCmd} setup --generate-auto-start fish | string collect)
      end
    '');

  programs.zsh.initExtra = mkIf hasZsh
    (mkOrder 200 ''
      if [ -z "$SUDO_USER" ];
      then
        eval "$(${zellijCmd} setup --generate-auto-start zsh)"
      fi
    '');
}
