{ lib, osConfig, ... }:

let
  colors = osConfig.theme.colors;
  font = osConfig.theme.font;
  monitors = lib.attrValues osConfig.theme.monitors;
  primaryMonitorName = osConfig.theme.primaryMonitor;
  primaryMonitorCfg = lib.findFirst (m: m.name == primaryMonitorName) {} monitors;

  # Tactical Scale Calculation (Logical Height / 1080)
  # Quickshell handles compositor scaling automatically, so our tactical 'scale'
  # multiplier should be based on logical units relative to a 1080p reference.
  physHeightStr = if primaryMonitorCfg ? mode && primaryMonitorCfg.mode != null 
                  then lib.last (lib.splitString "x" (lib.head (lib.splitString "@" primaryMonitorCfg.mode)))
                  else "1080";
  physHeight = lib.toInt physHeightStr;
  monitorScale = if primaryMonitorCfg ? scale then primaryMonitorCfg.scale else 1.0;
  logicalHeight = (1.0 * physHeight) / monitorScale;
  
  # Logical height of 1080p is 1080.
  # For your laptop (2880x1800 @ 1.666): 1800 / 1.666 = 1080 (scale 1.0)
  scale = logicalHeight / 1080.0;
in

{
  inherit colors font monitors primaryMonitorCfg primaryMonitorName scale;
}
