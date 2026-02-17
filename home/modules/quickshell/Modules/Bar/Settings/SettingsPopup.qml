import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import qs.Components
import qs.Config

PopupWindow {
    id: settingsPopup

    property var window
    property var bar
    property bool isLaptop: false
    property bool open: false
    readonly property int columns: 2
    readonly property int rows: isLaptop ? 3 : 2
    readonly property real availableHeight: {
        if (!window || !window.height) {
            return 900;
        }
        return Math.max(0, window.height - (Size.settingsPopupMargin * 2));
    }
    readonly property real availableWidth: {
        const screen = window ? window.screen : null;
        const screenWidth = screen && screen.width ? screen.width : 1920;
        const barWidth = bar && bar.contentWidth ? bar.contentWidth : 48;
        const reservedRight = 28;
        return Math.max(0, screenWidth - barWidth - (Size.settingsPopupMargin * 2) - reservedRight);
    }
    readonly property real tileWidth: Math.max(140, Math.min(Size.settingsBoxWidth, (availableWidth - Size.settingsPopupSpacing) / columns))
    readonly property real tileHeight: Math.max(42, Math.min(Size.settingsBoxHeight, (availableHeight - (Size.settingsPopupSpacing * (rows - 1))) / rows))

    color: "transparent"
    visible: content.transformX != -rect.width
    implicitWidth: rect.width
    implicitHeight: rect.height

    anchor.window: window
    anchor.adjustment: PopupAdjustment.None
    anchor.rect.x: bar.contentWidth - 2
    anchor.rect.y: bar.height - settingsPopup.height

    Item {
        id: content
        property real transformTopCornerX: settingsPopup.open ? 0 : -rect.width
        property real transformX: settingsPopup.open ? 0 : -rect.width
        Behavior on transformTopCornerX {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
        Behavior on transformX {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        HuggingRectangle {
            id: rect
            leftEdge: true
            bottomEdge: true

            contentWidth: (settingsPopup.columns * settingsPopup.tileWidth) + ((settingsPopup.columns - 1) * Size.settingsPopupSpacing)
            contentHeight: (settingsPopup.rows * settingsPopup.tileHeight) + ((settingsPopup.rows - 1) * Size.settingsPopupSpacing)

            rectTranslateX: content.transformX
            leftRightTranslateX: content.transformX
            topBottomTranslateX: content.transformTopCornerX

            MarginWrapperManager {
                margin: Size.settingsPopupMargin
            }

            Grid {
                id: grid
                columns: settingsPopup.columns
                spacing: Size.settingsPopupSpacing
                width: (settingsPopup.columns * settingsPopup.tileWidth) + ((settingsPopup.columns - 1) * Size.settingsPopupSpacing)
                height: (settingsPopup.rows * settingsPopup.tileHeight) + ((settingsPopup.rows - 1) * Size.settingsPopupSpacing)

                BluetoothBox {
                    width: settingsPopup.tileWidth
                    height: settingsPopup.tileHeight
                }
                NetworkBox {
                    width: settingsPopup.tileWidth
                    height: settingsPopup.tileHeight
                }
                SpeakerSlider {
                    width: settingsPopup.tileWidth
                    height: settingsPopup.tileHeight
                }
                MicrophoneSlider {
                    width: settingsPopup.tileWidth
                    height: settingsPopup.tileHeight
                }
                BatteryBox {
                    visible: settingsPopup.isLaptop
                    width: settingsPopup.tileWidth
                    height: settingsPopup.tileHeight
                }
                BrightnessSlider {
                    visible: settingsPopup.isLaptop
                    width: settingsPopup.tileWidth
                    height: settingsPopup.tileHeight
                }
            }
        }
    }
}
