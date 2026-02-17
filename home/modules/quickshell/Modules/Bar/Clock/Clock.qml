import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.Components
import qs.Config
import qs.Services

Rectangle {
    id: rectangle
    color: Colorscheme.overlay
    implicitWidth: Size.barWidgetWidth
    implicitHeight: content.height
    radius: Size.borderRadiusSmall
    border.width: 1
    border.color: Colorscheme.love

    MarginWrapperManager {
        margin: 5
    }

    ColumnLayout {
        id: content

        ColumnLayout {
            spacing: 0
            Text {
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 14
                font.bold: true
                text: Time.day
                color: Colorscheme.gold
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 10
                text: Time.month
                color: Colorscheme.gold
            }
        }

        Rectangle {
            implicitHeight: 1
            implicitWidth: parent.implicitWidth
            color: Colorscheme.text
        }

        ColumnLayout {
            spacing: 0
            Layout.alignment: Qt.AlignHCenter
            Text {
                font.pixelSize: 12
                font.bold: true
                text: Time.hours
                color: Colorscheme.gold
            }
            Text {
                font.pixelSize: 12
                font.bold: true
                text: Time.minutes
                color: Colorscheme.gold
            }
        }
    }
}
