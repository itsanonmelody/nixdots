inputs:
{
  cursorIcons = import ./cursor-icons.nix inputs;
  grubThemes = import ./grub-themes.nix inputs;
  rustPackages = import ./rust-packages.nix inputs;
  sddmThemes = import ./sddm-themes.nix inputs;
}
