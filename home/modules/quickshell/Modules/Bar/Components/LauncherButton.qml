import Quickshell
import qs.Config
import qs.Modules.Bar.Components

BarButton {
    color: Colorscheme.gold
    colorHover: Colorscheme.foam
    icon: "fa_rocket.svg"
    onClicked: {
        Quickshell.execDetached(["qs", "ipc", "call", "launcher", "toggle"]);
    }
}
