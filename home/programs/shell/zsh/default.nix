{ lib, ... }:
with lib;
{
  programs.zsh = {
    enable = true;
    initExtraFirst = mkDefault ''
      PS1='[%n@%m] %2~%# '
    '';
  };
}
