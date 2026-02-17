import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import Quickshell.Widgets
import qs.Components
import qs.Config

MouseArea {
    id: mouseArea
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    implicitWidth: Size.barWidgetWidth
    implicitHeight: rectangle.height
    Layout.alignment: Qt.AlignHCenter

    property var popup
    property bool isLaptop: false
    readonly property var displayDevice: UPower.displayDevice
    property bool hasBattery: displayDevice ? displayDevice.isLaptopBattery : false
    readonly property color iconColor: mouseArea.containsMouse ? Colorscheme.foam : Colorscheme.gold

    onClicked: {
        popup.open = !popup.open;
    }

    Rectangle {
        id: rectangle
        width: mouseArea.implicitWidth
        color: mouseArea.containsMouse ? Colorscheme.surface : Colorscheme.overlay
        radius: Size.borderRadiusSmall
        border.width: 1
        border.color: Colorscheme.love

        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }

        MarginWrapperManager {
            margin: Size.settingsStatusPadding
        }

        ColumnLayout {
            id: content
            anchors.centerIn: parent
            spacing: Size.settingsStatusSpacing

            NetworkStatus {
                iconColor: mouseArea.iconColor
                Layout.alignment: Qt.AlignHCenter
            }
            BluetoothStatus {
                iconColor: mouseArea.iconColor
                Layout.alignment: Qt.AlignHCenter
            }
            VolumeStatus {
                iconColor: mouseArea.iconColor
                Layout.alignment: Qt.AlignHCenter
            }
            MicrophoneStatus {
                iconColor: mouseArea.iconColor
                Layout.alignment: Qt.AlignHCenter
            }
            SvgIcon {
                color: mouseArea.iconColor
                source: {
                    if (!mouseArea.hasBattery) {
                        return "fa_bolt.svg";
                    }
                    if (displayDevice.percentage >= 0.90) {
                        return "fa_battery_full.svg";
                    } else if (displayDevice.percentage >= 0.75) {
                        return "fa_battery_three_quarters.svg";
                    } else if (displayDevice.percentage >= 0.5) {
                        return "fa_battery_half.svg";
                    } else if (displayDevice.percentage >= 0.25) {
                        return "fa_battery_quarter.svg";
                    }
                    return "fa_battery_empty.svg";
                }
                size: Size.settingsBoxIconSize
                visible: mouseArea.isLaptop && mouseArea.hasBattery
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
