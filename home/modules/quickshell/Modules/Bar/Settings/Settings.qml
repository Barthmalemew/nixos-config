import QtQuick
import qs.Config

MouseArea {
    id: mouseArea
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    implicitWidth: content.width
    implicitHeight: content.height

    property var popup
    property bool isLaptop: false

    onClicked: {
        popup.open = !popup.open;
    }

    Rectangle {
        id: content
        width: 32
        height: 32
        radius: Size.borderRadiusSmall
        color: mouseArea.containsMouse ? Colorscheme.hover : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }

        Text {
            anchors.centerIn: parent
            text: "\u2699"
            font.pixelSize: 22
            color: Colorscheme.text

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }
        }
    }
}
