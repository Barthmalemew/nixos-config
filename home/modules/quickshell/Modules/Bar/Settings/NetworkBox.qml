import QtQuick
import Quickshell
import qs.Config
import qs.Components
import qs.Services

MouseArea {
    id: root
    width: Size.settingsBoxWidth
    height: Size.settingsBoxHeight
    cursorShape: Qt.PointingHandCursor

    property bool enabled: Network.connected
    property color background: enabled ? Colorscheme.gold : Colorscheme.overlay
    property color foreground: Colorscheme.text

    onClicked: {
        Quickshell.execDetached(["nmcli", "radio", "wifi", "toggle"]);
        Network.refresh();
    }

    Rectangle {
        anchors.fill: parent
        radius: Size.borderRadiusLarge

        color: root.background

        Row {
            anchors.centerIn: parent
            spacing: Size.settingsBoxSpacing
            SvgIcon {
                anchors.verticalCenter: parent.verticalCenter
                source: Network.activeConnectionIcon
                size: Size.settingsBoxIconSize
                color: root.foreground
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: Size.settingsBoxFontSize
                font.bold: true
                text: Network.activeConnection
                color: root.foreground
                width: Math.max(0, root.width - (Size.settingsBoxIconSize + (Size.settingsBoxSpacing * 3)))
                elide: Text.ElideRight
            }
        }
    }
}
