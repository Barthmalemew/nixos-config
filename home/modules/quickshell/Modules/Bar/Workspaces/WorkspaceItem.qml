import Quickshell
import QtQuick
import qs.Config
import qs.Components
import qs.Services

Item {
    required property var modelData
    property string icon: {
        const icons = {
            "terminal": "fa_terminal.svg",
            "dev": "fa_dev.svg",
            "browser": "fa_globe.svg",
            "chat": "fa_comment.svg",
            "browserdev": "fa_flask_vial.svg",
            "other": "fa_window_restore.svg",
            "notes": "fa_note_sticky.svg"
        };
        const fallbackIcons = [
            "fa_terminal.svg",
            "fa_globe.svg",
            "fa_comment.svg",
            "fa_dev.svg",
            "fa_flask_vial.svg",
            "fa_window_restore.svg",
            "fa_note_sticky.svg"
        ];
        const workspaceName = typeof modelData.name === "string" ? modelData.name : "";
        const workspaceKey = workspaceName.length > 2 ? workspaceName.slice(0, -2) : workspaceName;
        if (icons[workspaceKey]) {
            return icons[workspaceKey];
        }

        const idx = parseInt(modelData.idx, 10);
        if (!isNaN(idx) && idx > 0) {
            return fallbackIcons[(idx - 1) % fallbackIcons.length];
        }

        return "fa_plus.svg";
    }

    visible: modelData.output == barWindow.modelData.name
    implicitWidth: mouseArea.implicitWidth
    implicitHeight: mouseArea.implicitHeight

    MouseArea {
        id: mouseArea
        implicitWidth: rectangle.implicitWidth
        implicitHeight: rectangle.implicitHeight
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", modelData.idx]);
        }

        Rectangle {
            id: rectangle
            anchors.fill: parent
            color: modelData.isActive ? Colorscheme.highlightMed : Colorscheme.surface
            implicitWidth: svg.width + 6
            implicitHeight: modelData.isActive ? svg.width + 18 : svg.width + 6
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
                color: modelData.isActive ? Colorscheme.iris : mouseArea.containsMouse ? Colorscheme.foam : Colorscheme.text
                source: icon
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
