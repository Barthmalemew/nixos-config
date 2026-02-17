import QtQuick
import qs.Config
import qs.Components
import qs.Services

Item {
    id: root
    implicitWidth: svgIcon.width
    implicitHeight: svgIcon.height
    property color iconColor: Colorscheme.gold

    SvgIcon {
        id: svgIcon
        color: root.iconColor
        source: Network.activeConnectionIcon
        size: Size.settingsBoxIconSize
        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }
    }
}
