import Quickshell
import qs.Config
import qs.Modules.Bar.Components

BarButton {
    color: Colorscheme.gold
    colorHover: Colorscheme.foam
    icon: "fa_power_off.svg"
    onClicked: {
        Quickshell.execDetached(["niri", "msg", "action", "quit"]);
    }
}
