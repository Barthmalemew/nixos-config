import QtQuick
import qs.Config
import qs.Components
import Quickshell.Bluetooth

Item {
    id: root
    implicitWidth: svgIcon.width
    implicitHeight: svgIcon.height
    readonly property var adapter: Bluetooth.defaultAdapter
    property bool enabled: adapter ? adapter.enabled : false

    SvgIcon {
        id: svgIcon
        color: root.enabled ? Colorscheme.text : Colorscheme.muted
        source: "fa_bluetooth_b.svg"
        size: 24
    }
}
