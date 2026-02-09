{ osConfig, lib, pkgs, ... }:
 
 let
-  # Access the theme and hardware truth from the NixOS configuration
-  theme = osConfig.theme.colors;
-  isLaptop = osConfig.theme.isLaptop;
-  primaryMonitor = osConfig.theme.primaryMonitor;
-  
-  # Find the primary monitor config in the system monitors list
-  primaryMonitorCfg = lib.findFirst (m: m.name == primaryMonitor) {} (lib.attrValues osConfig.theme.monitors);
-  
-  # Extract physical height from mode string like "2880x1800@120.000"
-  physHeightStr = if primaryMonitorCfg ? mode && primaryMonitorCfg.mode != null 
-                  then lib.last (lib.splitString "x" (lib.head (lib.splitString "@" primaryMonitorCfg.mode)))
-                  else "1080";
-              
-  physHeight = lib.toInt physHeightStr;
-  
-  # Account for the monitor's scale factor to get LOGICAL height.
-  # If 1800p is scaled by 1.66, logical height is 1080.
-  # Quickshell handles compositor scaling automatically, so our tactical 'scale'
-  # multiplier should be based on logical units relative to 1080p.
-  monitorScale = if primaryMonitorCfg ? scale then primaryMonitorCfg.scale else 1.0;
-  logicalHeight = (1.0 * physHeight) / monitorScale;
-  
-  # Tactical Scale = Logical Height / 1080
-  # For your laptop: 1080 / 1080 = 1.0 (Correct)
-  scale = logicalHeight / 1080.0;
+  themeHelper = import ./theme-helper.nix { inherit lib osConfig; };
+  theme = themeHelper.colors;
+  isLaptop = osConfig.theme.isLaptop;
+  primaryMonitor = themeHelper.primaryMonitorName;
+  scale = themeHelper.scale;
 
   # Absolute paths for assets


  # Absolute paths for assets
  asukaPath = ../../config/quickshell/assets/asuka.png;
  maskPath = ../../config/quickshell/assets/unit2-foreground.png;

  # Define the generated Colors.qml content
  colorsQml = ''
    import QtQuick

    QtObject {
      readonly property bool isLaptop: ${if isLaptop then "true" else "false"}
      readonly property string primaryMonitor: "${primaryMonitor}"
      readonly property real scale: ${toString scale}

      // Tooling paths
      readonly property string niriBin: "${pkgs.niri}/bin/niri"
      readonly property string nmcliBin: "${pkgs.networkmanager}/bin/nmcli"
      readonly property string wpctlBin: "${pkgs.wireplumber}/bin/wpctl"

      // Absolute Asset Paths
      readonly property url asukaPath: "file://${asukaPath}"
      readonly property url maskPath: "file://${maskPath}"

      readonly property string background: "${theme.background}"
      readonly property string foreground: "${theme.foreground}"
      readonly property string cursor: "${theme.cursor}"

      readonly property string panelBg: "${theme.panelBg}"
      readonly property string panelBg2: "${theme.panelBg2}"
      readonly property string panelBorder: "${theme.panelBorder}"
      readonly property string muted: "${theme.muted}"
      readonly property string outline: "${theme.outline}"

      // Tactical Elements
      readonly property string launcherOverlay: "#cc000000"
      readonly property string emptyRail: "#151618"
      readonly property string darkSurface: "#080809"
      readonly property string midSurface: "#141518"
      readonly property string deepSurface: "#0b0b0c"

      readonly property string clockHour: "${theme.red}"
      readonly property string clockMinute: "${theme.red}"
      readonly property string clock: "${theme.red}"

      readonly property string color0: "${theme.panelBg}"
      readonly property string color1: "${theme.red}"
      readonly property string color2: "${theme.orange}"
      readonly property string color3: "${theme.darkRed}"
      readonly property string color4: "${theme.green}"
      readonly property string color5: "${theme.highlight}"
      readonly property string color6: "${theme.orange}"
      readonly property string color7: "${theme.foreground}"
      readonly property string color8: "${theme.dim}"
      readonly property string color9: "${theme.highlight}"
      readonly property string color10: "${theme.orange}"
      readonly property string color11: "${theme.orange}"
      readonly property string color12: "${theme.red}"
      readonly property string color13: "${theme.orange}"
      readonly property string color14: "${theme.foreground}"
      readonly property string color15: "${theme.foreground}"

      readonly property string black: "#000000"
      readonly property string red: color1
      readonly property string green: color4
      readonly property string yellow: color5
      readonly property string blue: color4
      readonly property string magenta: color5
      readonly property string cyan: color6
      readonly property string white: foreground

      readonly property string brightBlack: color8
      readonly property string brightRed: color1
      readonly property string brightGreen: color4
      readonly property string brightYellow: color11
      readonly property string brightBlue: color12
      readonly property string brightMagenta: color5
      readonly property string brightCyan: color6
      readonly property string brightWhite: foreground
    }
  '';

  # Assemble the entire Quickshell config directory as a single derivation
  quickshellConfig = pkgs.runCommand "quickshell-config" {} ''
    mkdir -p $out
    cp -r ${../../config/quickshell}/. $out/
    mkdir -p $out/theme
    chmod -R +w $out/theme
    cat > $out/theme/Colors.qml <<EOF
    ${colorsQml}
    EOF
  '';
in

{
  # ---------------------------------------------------------------------------
  # QUICKSHELL CONFIGURATION
  # ---------------------------------------------------------------------------
  xdg.configFile."quickshell" = {
    source = quickshellConfig;
    force = true;
  };
}
