{ pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # NIX SYSTEM MAINTENANCE
  # ---------------------------------------------------------------------------
  # This module handles the "health" of the Nix store. 
  # It keeps the system clean and optimizes disk usage automatically.

  nix = {
    settings = {
      # Automatically hard-link identical files in the store to save space.
      # Extremely effective on laptops with limited SSD storage.
      auto-optimise-store = true;
      
      # Enable experimental features for Flakes
      experimental-features = [ "nix-command" "flakes" ];
      
      # Binary Caches for faster installs
      substituters = [
        "https://cache.nixos.org"
        "https://mandrid.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "mandrid.cachix.org-1:G0qaL68v4rfvk5S5CqroPoS63TmXOOyZIoPPNH1b1MY="
      ];
    };

    # Garbage Collection
    # We leave this manual to avoid deleting generations you still want.
    # Use the 'clean' alias to tidy up manually.
    gc = {
      automatic = false;
    };
  };

  nixpkgs.config.allowUnfree = true;
}
