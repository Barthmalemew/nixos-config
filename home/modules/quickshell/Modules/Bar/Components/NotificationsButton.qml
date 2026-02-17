import qs.Config
import qs.Modules.Bar.Components

BarButton {
    property var popup
    color: Colorscheme.rose
    colorHover: Colorscheme.foam
    icon: "fa_bell.svg"
    onClicked: {
        popup.open = !popup.open
    }
}
