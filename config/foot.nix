{ pkgs, ... }:

let
  # Keep these aligned with `config/quickshell/theme/Colors.qml` (tuned to the
  # Unit-02 wallpaper).
  palette = {
    background = "#34363a";
    foreground = "#efeae4";

    panelBg = "#26272a";

    color1 = "#c24f4f";
    color2 = "#d17936";
    color3 = "#b84a4a";
    color4 = "#a8ff00";
    color5 = "#cf5b5b";
    color6 = "#d17936";

    dim = "#7a7c80";
  };

  stripHash = s: builtins.replaceStrings [ "#" ] [ "" ] s;
  c = s: stripHash s;

in
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=11";
        pad = "12x12";
      };

      # foot expects hex without `#`
      colors = {
        background = c palette.background;
        foreground = c palette.foreground;

        regular0 = c palette.panelBg;
        regular1 = c palette.color1;
        regular2 = c palette.color2;
        regular3 = c palette.color3;
        regular4 = c palette.color4;
        regular5 = c palette.color5;
        regular6 = c palette.color6;
        regular7 = c palette.foreground;

        bright0 = c palette.dim;
        bright1 = c palette.color5;
        bright2 = c palette.color2;
        bright3 = c palette.color2;
        bright4 = c palette.color1;
        bright5 = c palette.color2;
        bright6 = c palette.foreground;
        bright7 = c palette.foreground;
      };

      csd = {
        preferred = "none";
      };
    };
  };
}