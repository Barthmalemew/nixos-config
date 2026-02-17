import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Config

PanelWindow {
    id: launcher
    anchors {
        top: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: launcher.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    exclusiveZone: 0
    color: "transparent"
    implicitWidth: rect.width
    implicitHeight: rect.height
    visible: transformY != -rect.height

    property var open: false
    property real transformY: open ? 0 : -rect.height
    property real transformCornerY: open ? 0 : -24

    readonly property list<DesktopEntry> visibleEntries: Array.from(DesktopEntries.applications.values).sort((d1, d2) => d1.name.localeCompare(d2.name)).filter(application => application.name.toLowerCase().includes(promptInput.text.toLowerCase()))
    property real selectedEntry: 0

    Behavior on transformY {
        DefaultNumberAnimation {}
    }
    Behavior on transformCornerY {
        DefaultNumberAnimation {}
    }

    Shortcut {
        sequences: [StandardKey.Cancel]
        onActivated: {
            launcher.open = false;
        }
    }

    HuggingRectangle {
        id: rect
        topEdge: true
        contentWidth: Size.launcherWidth
        contentHeight: content.height + (2 * Size.launcherOuterPadding)
        borderColor: Colorscheme.border

        rectTranslateY: launcher.transformY
        leftRightTranslateY: launcher.transformY

        ColumnLayout {
            id: content
            anchors.centerIn: parent
            spacing: Size.launcherOuterPadding

            Row {
                spacing: Size.launcherInnerPadding

                Rectangle {
                    id: promptIcon
                    implicitWidth: prompt.height
                    implicitHeight: prompt.height
                    color: Colorscheme.surface
                    radius: Size.borderRadiusLarge
                    SvgIcon {
                        anchors.centerIn: parent
                        source: "fa_rocket.svg"
                        color: Colorscheme.gold
                    }
                }
                Rectangle {
                    id: prompt
                    color: Colorscheme.surface
                    radius: Size.borderRadiusLarge
                    height: promptInput.height + (2 * Size.launcherInnerPadding)
                    width: Size.launcherWidth - (2 * Size.launcherOuterPadding) - prompt.height - Size.launcherInnerPadding

                    TextInput {
                        id: promptInput
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: prompt.left
                        anchors.right: prompt.right
                        anchors.leftMargin: Size.launcherInnerPadding
                        anchors.rightMargin: Size.launcherInnerPadding
                        clip: true
                        color: Colorscheme.text
                        font.pointSize: Size.launcherFontSize
                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Return) {
                                launcher.run();
                            } else if (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_N) {
                                launcher.selectedEntry++;
                            } else if (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_P) {
                                launcher.selectedEntry--;
                            }
                        }
                    }
                }
            }

            ListView {
                model: launcher.visibleEntries
                spacing: Size.launcherInnerPadding
                height: 180
                delegate: Rectangle {
                    id: delegateRect
                    property bool isSelected: index === launcher.selectedEntry
                    width: entry.width
                    height: entry.height + (2 * Size.launcherInnerPadding)
                    radius: Size.borderRadiusSmall
                    color: isSelected ? Colorscheme.highlightMed : Colorscheme.base

                    MouseArea {
                        id: entryMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            launcher.selectedEntry = index;
                        }
                        onClicked: {
                            launcher.selectedEntry = index;
                            launcher.run();
                        }
                    }

                    Row {
                        id: entry
                        anchors.centerIn: parent
                        width: rect.contentWidth - (2 * Size.launcherOuterPadding)
                        spacing: Size.launcherInnerPadding * 2
                        Item {
                            width: promptIcon.width
                            height: itemIcon.height
                            Image {
                                id: itemIcon
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 30
                                height: 30
                                source: Quickshell.iconPath(modelData.icon, true)
                            }
                        }
                        Text {
                            text: modelData.name
                            font.pointSize: Size.launcherFontSize
                            color: (entryMouse.containsMouse || delegateRect.isSelected) ? Colorscheme.accentHover : Colorscheme.text
                            width: parent.width - itemIcon.width - parent.spacing
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }

    function run() {
        launcher.open = false;
        launcher.visibleEntries[launcher.selectedEntry].execute();
    }

    IpcHandler {
        target: "launcher"
        function toggle() {
            if (!launcher.open) {
                promptInput.clear();
                promptInput.forceActiveFocus();
                launcher.selectedEntry = 0;
            }
            launcher.open = !launcher.open;
        }
    }
}
