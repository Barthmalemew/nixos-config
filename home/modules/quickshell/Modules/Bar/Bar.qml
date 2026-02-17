import Quickshell
import Quickshell.Services.UPower
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
        readonly property bool isLaptopHost: !!(UPower.displayDevice && UPower.displayDevice.isLaptopBattery)
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
        property real contentWidth: Size.barWidth

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
                    topMargin: Size.barSectionMargin
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: Size.barSectionSpacing

                LauncherButton {}
                Workspaces {}
            }

            ColumnLayout {
                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: Size.barSectionSpacing

                Clock {}
                NotificationsButton {
                    popup: notificationCenter
                }
            }

            ColumnLayout {
                anchors {
                    bottomMargin: Size.barSectionMargin
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: Size.barSectionSpacing

                Tray {}
                Settings {
                    popup: controlsPopup
                    isLaptop: barWindow.isLaptopHost
                }
                PowerButton {}
            }
        }

        SettingsPopup {
            id: controlsPopup
            window: barWindow
            bar: barContent
            isLaptop: barWindow.isLaptopHost
        }

        NotificationCenter {
            id: notificationCenter
            window: barWindow
            bar: barContent
        }
    }
}
