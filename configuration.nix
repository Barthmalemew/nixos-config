{ config, lib, pkgs, ... }:

{
  # Imports are now handled in the host-specific default.nix
  imports = [ ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "exfat" ];

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Networking
  # networking.hostName is defined in the host-specific default.nix
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  # Users
  users.users.barthmalemew = {
    isNormalUser = true;
    description = "Kevin Rouse";
    extraGroups = [ "wheel" "networkmanager" ]; 
    packages = with pkgs; [];
  };

  nixpkgs.config.allowUnfree = true;

  # Display Manager & Desktop
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  programs.niri.enable = true;
  programs.xwayland.enable = true;

  # System Packages
  # Only install core system utilities here. User-specific apps (GUI tools, etc.)
  # should go into home.nix to keep the system closure small.
  environment.systemPackages = with pkgs; [
    # Core Utilities
    vim 
    wget
    git
    
    # System Components
    xwayland
    udiskie
    gvfs
    brightnessctl
    playerctl
    pavucontrol
    
    # KDE/Qt Integration
    kdePackages.polkit-kde-agent-1
    kdePackages.qtsvg
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    QT_QPA_PLATFORM = "wayland;xcb";
    GDK_BACKEND = "wayland,x11";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
  };

  xdg.portal = {
    enable = true;
    # Prefer KDE dialogs, but keep GTK as fallback.
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "kde" "gtk" ];
  };

  # Services
  services.upower.enable = true;
  services.power-profiles-daemon.enable = lib.mkDefault true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Firmware
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = with pkgs; [
    sof-firmware
  ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
}
