import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.Modules.Bar.Workspaces
import qs.Modules.Bar.Components
import qs.Modules.Bar.Clock
import qs.Modules.Bar.Tray
import qs.Modules.Bar.Settings
import qs.Modules.Bar.Notifications
import qs.Components
import qs.Config

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: barWindow
        required property var modelData
        screen: modelData
        readonly property bool displayOne: !!(modelData && modelData.name && modelData.name.endsWith("-1"))
        readonly property bool isLaptopOutput: !!(modelData && modelData.name && modelData.name.startsWith("eDP"))
        visible: displayOne

        anchors {
            left: true
            top: true
            bottom: true
        }

        color: "transparent"
        exclusiveZone: displayOne ? barContent.contentWidth : 0
        WlrLayershell.layer: WlrLayer.Top
        mask: Region {
            item: barContent
        }
        implicitWidth: barContent.width
        property real contentWidth: 48

        HuggingRectangle {
            id: barContent
            bottomEdge: true
            topEdge: true
            leftEdge: true
            contentHeight: parent.height
            contentWidth: barWindow.contentWidth
            backgroundColor: Colorscheme.base
            borderColor: Colorscheme.border
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }

            ColumnLayout {
                anchors {
                    topMargin: 8
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: 8

                LauncherButton {}
                Workspaces {}
            }

            ColumnLayout {
                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: 8

                Clock {}
                NotificationsButton {
                    popup: notificationCenter
                }
            }

            ColumnLayout {
                anchors {
                    bottomMargin: 8
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: 8

                Tray {}
                Settings {
                    popup: controlsPopup
                    isLaptop: barWindow.isLaptopOutput
                }
                PowerButton {}
            }
        }

        SettingsPopup {
            id: controlsPopup
            window: barWindow
            bar: barContent
            isLaptop: barWindow.isLaptopOutput
        }

        NotificationCenter {
            id: notificationCenter
            window: barWindow
            bar: barContent
        }
    }
}
