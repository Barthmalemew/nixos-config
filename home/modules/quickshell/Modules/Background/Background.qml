import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.Components

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: root
        required property var modelData
        screen: modelData
        readonly property string outputName: modelData && modelData.name ? modelData.name : ""
        readonly property bool mainOutput: outputName.endsWith("-1")
        readonly property bool verticalWallpaperOutput: outputName.endsWith("-2")
        visible: mainOutput || verticalWallpaperOutput

        WlrLayershell.layer: WlrLayer.Background

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        Rectangle {
            anchors.fill: parent
            color: "#0b0f14"
        }

        Image {
            anchors.fill: parent
            fillMode: root.verticalWallpaperOutput ? Image.PreserveAspectFit : Image.PreserveAspectCrop
            horizontalAlignment: Image.AlignHCenter
            verticalAlignment: Image.AlignVCenter
            autoTransform: true
            source: {
                if (root.verticalWallpaperOutput) {
                    return Qt.resolvedUrl(Quickshell.shellPath("assets/wallpapers/optional-vertical.jpg"));
                }
                return Qt.resolvedUrl(Quickshell.shellPath("assets/wallpapers/wallpaper.jpg"));
            }
        }

        BackgroundClock {
            visible: root.verticalWallpaperOutput
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: 80
            }
        }
    }
}
