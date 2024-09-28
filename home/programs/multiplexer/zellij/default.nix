{ config, lib, pkgs, ... }:
let
  cfg = config.programs.zellij;
  packages = config.home.packages;
in
with lib;
{
  options.programs.zellij = {
    enableShellIntegration = mkEnableOption "shell integration";
  };

  config = {
    programs.zellij = {
      enable = true;
      enableBashIntegration = cfg.enableShellIntegration
        && (builtins.elem pkgs.bash packages);
      enableFishIntegration = cfg.enableShellIntegration
        && (builtins.elem pkgs.fish packages);
      enableZshIntegration = cfg.enableShellIntegration
        && (builtins.elem pkgs.zsh packages);
      settings = {
      };
    };
  };
}
