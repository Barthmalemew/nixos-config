import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "theme" as Theme

Scope {
    id: root
    property var screenInfo
    property bool enabled: true
    property bool shouldShow: false
    property bool hasFocus: false
    property var inputRef: null

    function toggle(): void { 
        if (shouldShow) close();
        else open();
    }

    function open(): void { 
        shouldShow = true;
        openTimer.restart();
    }

    function close(): void {
        hasFocus = false;
        closeTimer.restart();
    }

    Timer {
        id: openTimer
        interval: 10
        onTriggered: hasFocus = true
    }

    Timer {
        id: closeTimer
        interval: 10
        onTriggered: shouldShow = false
    }

    Theme.Colors { id: colors }

    // Resolution scaling factor (base 1080p logical)
    readonly property real scale: colors.scale

    ListModel {
        id: filteredModel
        function updateFilter(text) {
            clear();
            const lowerText = text.toLowerCase();
            const source = DesktopEntries.applications.values;
            for (let i = 0; i < source.length; i++) {
                const entry = source[i];
                if (!entry) continue;
                if (text === "" || entry.name.toLowerCase().includes(lowerText) || (entry.genericName && entry.genericName.toLowerCase().includes(lowerText))) {
                    append({
                        name: entry.name,
                        icon: entry.icon,
                        genericName: entry.genericName || "",
                        entry: entry
                    });
                }
            }
        }
    }

    LazyLoader {
        active: root.shouldShow
        
        PanelWindow {
            id: window
            screen: root.screenInfo
            anchors { top: true; bottom: true; left: true; right: true }
            color: "transparent"
            
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: root.hasFocus ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
            WlrLayershell.namespace: "qs-launcher"
            
            Component.onCompleted: {
                root.inputRef = input;
                filteredModel.updateFilter("");
                input.text = "";
                listView.currentIndex = 0;
                input.forceActiveFocus();
            }

            Rectangle {
                anchors.fill: parent
                color: colors.launcherOverlay
                MouseArea { 
                    anchors.fill: parent
                    onClicked: root.close() 
                }
            }

            Item {
                id: launcherContainer
                anchors.centerIn: parent
                width: 500 * root.scale
                height: 600 * root.scale

                Shape {
                    id: headerShape
                    width: launcherContainer.width
                    height: 50 * root.scale
                    anchors.top: parent.top
                    ShapePath {
                        fillColor: colors.color1
                        startX: 0; startY: 0
                        PathLine { x: headerShape.width; y: 0 }
                        PathLine { x: headerShape.width - (20 * root.scale); y: headerShape.height }
                        PathLine { x: 0; y: headerShape.height }
                        PathLine { x: 0; y: 0 }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "TACTICAL_LOADER // UNIT_02"
                        color: colors.black
                        font.pixelSize: 13 * root.scale
                        font.weight: 900
                        font.letterSpacing: 2 * root.scale
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }

                Rectangle {
                    anchors.top: parent.top
                    anchors.topMargin: headerShape.height
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: colors.panelBg
                    border.color: colors.color1
                    border.width: 2

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15 * root.scale
                        spacing: 15 * root.scale

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 45 * root.scale
                            color: colors.panelBg2
                            border.color: input.activeFocus ? colors.color4 : colors.panelBorder
                            border.width: 1

                            TextInput {
                                id: input
                                anchors.fill: parent
                                anchors.margins: 10 * root.scale
                                verticalAlignment: TextInput.AlignVCenter
                                color: colors.foreground
                                font.pixelSize: 18 * root.scale
                                font.family: "JetBrainsMono Nerd Font"
                                selectionColor: colors.color4
                                focus: true
                                
                                onTextChanged: {
                                    filteredModel.updateFilter(text);
                                    listView.currentIndex = 0;
                                }

                                Keys.onPressed: event => {
                                    if (event.key === Qt.Key_Down) { listView.incrementCurrentIndex(); event.accepted = true; }
                                    else if (event.key === Qt.Key_Up) { listView.decrementCurrentIndex(); event.accepted = true; }
                                    else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                                        if (listView.currentItem) listView.currentItem.launch();
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Escape) { 
                                        root.close(); 
                                        event.accepted = true; 
                                    }
                                }
                            }
                        }

                        ListView {
                            id: listView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            model: filteredModel
                            clip: true
                            spacing: 2
                            
                            highlight: Rectangle {
                                color: colors.color4
                                opacity: 0.2
                                border.color: colors.color4
                                border.width: 1
                            }
                            highlightMoveDuration: 150
                            highlightResizeDuration: 0
                            
                            delegate: Item {
                                id: del
                                width: listView.width
                                height: 55 * root.scale
                                
                                function launch() {
                                    model.entry.execute();
                                    root.close();
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: del.launch()
                                    onEntered: listView.currentIndex = index
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10 * root.scale
                                    anchors.rightMargin: 10 * root.scale
                                    spacing: 15 * root.scale

                                    IconImage {
                                        source: model.icon ? "image://icon/" + model.icon : "image://icon/application-x-executable"
                                        width: 32 * root.scale; height: 32 * root.scale
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Column {
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                        Text {
                                            text: model.name.toUpperCase()
                                            color: del.ListView.isCurrentItem ? colors.color4 : colors.foreground
                                            font.pixelSize: 14 * root.scale
                                            font.weight: 700
                                            font.family: "JetBrainsMono Nerd Font"
                                        }
                                        Text {
                                            text: model.genericName.toUpperCase()
                                            color: colors.muted
                                            font.pixelSize: 9 * root.scale
                                            font.family: "JetBrainsMono Nerd Font"
                                            opacity: 0.6
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
