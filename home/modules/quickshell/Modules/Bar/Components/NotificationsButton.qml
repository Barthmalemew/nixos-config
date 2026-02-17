import qs.Config
import qs.Modules.Bar.Components

BarButton {
    property var popup
    color: Colorscheme.love
    colorHover: Colorscheme.foam
    icon: "fa_bell.svg"
    onClicked: {
        popup.open = !popup.open
    }
}
