import Quickshell
import QtQuick
import qs.Config
import qs.Components
import qs.Services

Item {
    required property int idx
    required property bool isActive
    required property string output
    readonly property string iconSource: {
        const idxKey = String(idx);
        if (Niri.workspaceIconsByIdx && Niri.workspaceIconsByIdx[idxKey]) {
            return Niri.workspaceIconsByIdx[idxKey];
        }
        return "fa_plus.svg";
    }

    visible: output == barWindow.modelData.name
    implicitWidth: mouseArea.implicitWidth
    implicitHeight: mouseArea.implicitHeight

    MouseArea {
        id: mouseArea
        implicitWidth: rectangle.implicitWidth
        implicitHeight: rectangle.implicitHeight
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", idx]);
        }

        Rectangle {
            id: rectangle
            anchors.fill: parent
            color: isActive ? Colorscheme.highlightMed : Colorscheme.surface
            implicitWidth: svg.width + 6
            implicitHeight: isActive ? svg.width + 18 : svg.width + 6
            radius: 9

            Behavior on implicitHeight {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }

            SvgIcon {
                id: svg
                anchors.centerIn: parent
                color: mouseArea.containsMouse ? Colorscheme.foam : Colorscheme.gold
                source: iconSource
                width: 20
                height: 20
                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }
            }
        }
    }
}
