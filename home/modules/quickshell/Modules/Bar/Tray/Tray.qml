import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import qs.Config

Item {
    id: root
    property bool open: false

    Layout.alignment: Qt.AlignHCenter
    implicitWidth: Size.barWidgetWidth
    implicitHeight: openButton.height + trayItems.height

    TrayButton {
        id: openButton
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: {
            root.open = !root.open;
        }
        transform: Rotation {
            angle: root.open ? 180 : 0
            origin.x: openButton.width / 2
            origin.y: openButton.height / 2
        }
    }

    Column {
        id: trayItems
        anchors.top: openButton.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        clip: true

        height: root.open ? implicitHeight : 0
        topPadding: 5

        Behavior on height {
            NumberAnimation {
                duration: 200
            }
        }

        spacing: 10
        Repeater {
            model: SystemTray.items
            delegate: TrayItem {}
        }
    }
}
