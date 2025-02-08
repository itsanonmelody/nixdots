inputs:
{
  lib = import ./lib inputs;
  modules = import ./modules inputs;
  pkgs = import ./packages inputs;
  scripts = import ./scripts inputs;
}
