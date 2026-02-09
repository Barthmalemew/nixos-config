{ config, osConfig, lib, nvf, mandrid, pkgs, ... }:
 
 let
   themeHelper = import ./theme-helper.nix { inherit lib osConfig; };
   cursor = config.home.pointerCursor;
   customNvf = nvf.lib.mkNeovim { theme = { colors = themeHelper.colors; }; };
 in


{
  # ---------------------------------------------------------------------------
  # SHELL & TERMINAL UTILITIES
  # ---------------------------------------------------------------------------
  # This file defines your command-line environment, aliases, and variables.

  # Shell Aliases
  # Short commands for common tasks to save keystrokes.
  home.shellAliases = {
    # NixOS Maintenance
    rebuild = "sudo nixos-rebuild switch --flake ."; # Apply system changes
    upd = "nix flake update";                        # Update package versions (flake.lock)
    clean = "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +5 && nix-collect-garbage -d"; # Keep last 5, then clean store
    conf = "cd ~/nixos-config";                      # Jump to config directory
    logs = "journalctl --user -u";                   # Check service logs (e.g. 'logs quickshell')
  };

  # Environment Variables
  home.sessionVariables = {
    # Ensure the cursor theme applies to X11 apps running in Wayland
    XCURSOR_THEME = cursor.name;
    XCURSOR_SIZE = toString cursor.size;
  };

  # Packages
  # These are command-line tools available in your shell.
  home.packages = with pkgs; [
    # Core Tools
    fastfetch   # System information fetcher (prettier neofetch)
    python3
    gemini-cli
    opencode
    codex
    rembg
    git
    customNvf
    mandrid.packages.${pkgs.stdenv.hostPlatform.system}.default
    
    # File Management
    yazi        # Terminal file manager (fast, modern)
    
    # Editors
    # Note: NVF (Neovim) is injected via the module system in home.nix
    
    # Archives & Utils
    zip
    unzip
    ripgrep     # Super fast 'grep' alternative
    jq          # JSON processor
  ];
}
