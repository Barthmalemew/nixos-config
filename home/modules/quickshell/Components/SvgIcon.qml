import Quickshell
import QtQuick
import QtQuick.Effects

Item {
    id: root
    property string source: ""
    property color color: "#d7dee8"
    property real size: 30

    width: root.size
    height: root.size

    Image {
        id: icon
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        smooth: true
        source: root.source ? Qt.resolvedUrl(Quickshell.shellPath("assets/icons/" + root.source)) : ""
        opacity: 0
    }

    MultiEffect {
        anchors.fill: parent
        source: icon
        brightness: 1.0
        colorization: 1.0
        colorizationColor: root.color
    }
}
