{ config, lib, pkgs, ... }:
let
  packages = config.home.packages;
in
with lib;
{
  programs.zsh = {
    enable = true;
    initExtraFirst = mkDefault ''
      PS1='[%n@%m] %2~%# '
    '';
    initExtra = strings.optionalString
      (builtins.elem pkgs.zellij packages)
      ''
        # https://github.com/zellij-org/zellij/issues/1933
        eval "$(zellij setup --generate-completion zsh | tail -n13)"
      '';
  };
}
