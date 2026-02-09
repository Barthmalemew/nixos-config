{ pkgs, ... }:

{
  # --- Storage Maintenance ---
  # Periodically discard unused SSD blocks.
  services.fstrim.enable = true;

  # --- System Packages ---
  # Core system utilities only. User applications belong in home.nix.
  environment.systemPackages = with pkgs; [
    # Editors & Tools
    vim 
    wget
    git
    
    # System Components
    udiskie
    gvfs
    brightnessctl
    playerctl
    pavucontrol
    
    # KDE/Qt Integration
    kdePackages.polkit-kde-agent-1
    kdePackages.qtsvg
  ];
}
