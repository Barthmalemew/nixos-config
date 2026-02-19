{ pkgs, colorscheme, ... }:

let
  c = colorscheme;

  # Build a filtered copy of the quickshell source tree, excluding
  # the static Colorscheme.qml (we generate it from colorscheme.nix).
  quickshellFiltered = pkgs.runCommandLocal "quickshell-config" {} ''
    cp -r ${./.} $out
    chmod -R u+w $out
    rm -f $out/default.nix
    rm -f $out/Config/Colorscheme.qml
    cat > $out/Config/Colorscheme.qml << 'QML'
    pragma Singleton

    import Quickshell
    import QtQuick

    Singleton {
        readonly property color base: "${c.base}"
        readonly property color surface: "${c.surface}"
        readonly property color overlay: "${c.overlay}"
        readonly property color text: "${c.text}"
        readonly property color subtle: "${c.subtle}"
        readonly property color muted: "${c.muted}"
        readonly property color gold: "${c.orange}"
        readonly property color rose: "${c.red}"
        readonly property color iris: "${c.red}"
        readonly property color foam: "${c.green}"
        readonly property color pine: "${c.greenDim}"
        readonly property color hover: "#44${builtins.substring 1 6 c.green}"
        readonly property color love: "${c.red}"
        readonly property color highlightLow: "${c.highlightLow}"
        readonly property color highlightMed: "${c.highlightMed}"
        readonly property color highlightHigh: "${c.highlightHigh}"
        readonly property color border: "${c.muted}"

        readonly property color accentPrimary: iris
        readonly property color accentSecondary: gold
        readonly property color accentHover: foam
        readonly property color selectedBackground: hover
        readonly property color selectedBorder: foam
    }
    QML
  '';
in
{
  xdg.configFile."quickshell" = {
    source = quickshellFiltered;
    recursive = true;
  };
}
