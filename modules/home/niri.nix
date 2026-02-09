{ osConfig, lib, ... }:
 
 let
-  theme = osConfig.theme.colors;
+  themeHelper = import ./theme-helper.nix { inherit lib osConfig; };
+  theme = themeHelper.colors;
 
   # Function to turn our Nix monitor attributes into Niri KDL blocks
@@
   '';
 
   # Generate all monitor blocks for the current host
-  outputs = lib.concatStringsSep "\n" (lib.mapAttrsToList mkOutput osConfig.theme.monitors);
+  outputs = lib.concatStringsSep "\n" (lib.mapAttrsToList mkOutput osConfig.theme.monitors);
 
   # Keep the hand-edited KDL as the source of truth, then inject host outputs

  # and theme colors so you can tweak the config without fighting Nix strings.
  baseConfig = builtins.readFile ../../config/niri/config.kdl;
  withOutputs = builtins.replaceStrings [ "// __NIRI_OUTPUTS__" ] [ outputs ] baseConfig;
  themedConfig = builtins.replaceStrings
    [ "\"#c24f4f\"" "\"#7a7c80\"" ]
    [ "\"${theme.red}\"" "\"${theme.dim}\"" ]
    withOutputs;
in
{
  xdg.configFile."niri/config.kdl" = {
    text = themedConfig;
    force = true;
  };
}
