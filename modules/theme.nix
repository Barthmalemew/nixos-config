{ lib, config, ... }:

let
  # Shorthand for the option type we use everywhere here.
  # We use 'str' because colors are just hex strings like "#ff0000".
  str = lib.types.str;
  mkOpt = lib.mkOption;
in
{
  # ---------------------------------------------------------------------------
  # OPTION DECLARATIONS (The Interface)
  # ---------------------------------------------------------------------------
  # This defines the "schema" for your theme. By defining these as options,
  # we gain:
  # 1. Type safety (Nix will error if you try to set a color to a number).
  # 2. Mergeability (You can define base colors here, and override just ONE
  #    color in a specific host configuration without replacing the whole set).
  # 3. Documentation (The 'description' field helps tools like man pages).
  
  options.theme = {
    # Typography
    font = {
      monospace = mkOpt { type = str; default = "JetBrainsMono Nerd Font"; description = "Primary monospace font name"; };
      size = mkOpt { type = lib.types.int; default = 11; description = "Base font size"; };
    };

    isLaptop = mkOpt { type = lib.types.bool; default = false; description = "Whether the current host is a laptop"; };
    primaryMonitor = mkOpt { type = str; default = ""; description = "The name of the primary monitor (e.g. eDP-1)"; };

    # Hardware / Monitor Layout
    # This allows us to define different screen setups per host
    monitors = mkOpt {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          name = mkOpt { type = str; };
          mode = mkOpt { type = lib.types.nullOr str; default = null; };
          scale = mkOpt { type = lib.types.number; default = 1.0; };
          position = mkOpt { type = lib.types.nullOr str; default = null; };
          transform = mkOpt { type = lib.types.nullOr str; default = null; };
        };
      });
      default = {};
    };

    colors = {
      # Base Interface
      background = mkOpt { type = str; description = "Primary background color"; };
      foreground = mkOpt { type = str; description = "Primary foreground (text) color"; };
      cursor     = mkOpt { type = str; description = "Cursor color"; };

      # UI Elements
      panelBg     = mkOpt { type = str; description = "Main panel/bar background"; };
      panelBg2    = mkOpt { type = str; description = "Secondary/darker panel background"; };
      panelBorder = mkOpt { type = str; description = "Border color for panels"; };
      muted       = mkOpt { type = str; description = "Muted/disabled text color"; };
      outline     = mkOpt { type = str; description = "Focus outline or active border"; };

      # Palette (The Semantic Colors)
      red       = mkOpt { type = str; };
      orange    = mkOpt { type = str; };
      darkRed   = mkOpt { type = str; };
      green     = mkOpt { type = str; };
      highlight = mkOpt { type = str; };
      dim       = mkOpt { type = str; };
    };
  };

  # ---------------------------------------------------------------------------
  # CONFIGURATION (The Implementation)
  # ---------------------------------------------------------------------------
  # This sets the actual values for the options defined above.
  # We use 'lib.mkDefault' to allow these to be easily overridden.
  # If you want a specific host (e.g., laptop) to have a different background,
  # you just set 'theme.colors.background = "..."' in that host's config,
  # and it will take precedence over this default.

  config.theme.colors = import ./palette.nix;
}
