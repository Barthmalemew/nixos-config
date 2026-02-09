{ pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # USER APPLICATIONS (GUI)
  # ---------------------------------------------------------------------------
  # Graphical apps live here so home.nix stays lean and predictable.
  # CLI tools belong in modules/home/shell.nix.

  home.packages = with pkgs; [
    vivaldi
    quickshell
    obsidian
    obs-studio
    kdePackages.dolphin
    swaybg
    grim
    slurp
    wl-clipboard
  ];
}
