import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import Quickshell.Services.UPower

import "theme" as Theme

Scope {
    id: root

    property var screen
    property bool enabled: true

    Theme.Colors { id: colors }
    readonly property real scale: colors.scale

    readonly property int barH: Math.round(36 * scale)
    readonly property int padX: Math.round(18 * scale)

    // Visibility is driven by NiriActivity
    property bool shouldShow: false
    property real offsetY: 0

    // PanelWindow is inside a LazyLoader, so we control visibility via a
    // root-level flag instead of referencing the window id.
    property bool barVisible: false

    Timer {
        id: hideKick
        interval: 260
        repeat: false
        onTriggered: root.barVisible = false
    }

    Behavior on offsetY {
        NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
    }

    onShouldShowChanged: {
        if (shouldShow) {
            hideKick.stop();
            root.barVisible = true;
            offsetY = -barH;
            // next tick: animate in
            Qt.callLater(() => { offsetY = 0; });
        } else {
            offsetY = -barH;
            hideKick.restart();
        }
    }

    // --- Models ---
    NiriActivity {
        id: niri
        active: root.enabled
        onHasWindowsChanged: root.shouldShow = niri.hasWindows
        Component.onCompleted: root.shouldShow = niri.hasWindows
    }

    // WiFi status (nmcli)
    property string wifiText: "…"

    Process {
        id: nmcli
        command: [colors.nmcliBin, "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "dev", "status"]
        stdout: SplitParser {
            onRead: data => {
                const lines = (data || "").trim().split("\n");
                let wifiName = "";
                let wifiState = "";
                for (let i = 0; i < lines.length; i++) {
                    const parts = lines[i].split(":");
                    if (parts.length < 4) continue;
                    const type = parts[1];
                    const state = parts[2];
                    const conn = parts.slice(3).join(":");
                    if (type !== "wifi") continue;
                    wifiState = state;
                    if (state === "connected") wifiName = conn;
                }

                if (wifiName && wifiName.length > 0) root.wifiText = wifiName;
                else if (wifiState === "unavailable") root.wifiText = "WiFi Off";
                else if (wifiState === "disconnected") root.wifiText = "No WiFi";
                else if (wifiState && wifiState.length > 0) root.wifiText = "WiFi";
                else root.wifiText = "WiFi";
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: { if (!nmcli.running) nmcli.running = true; }
    }

    // Battery (UPower service)
    readonly property var batt: UPower.displayDevice
    readonly property real battPctRaw: batt ? batt.percentage : 1.0
    readonly property int battPct: batt ? Math.round((battPctRaw <= 1.0) ? (battPctRaw * 100) : battPctRaw) : 100
    readonly property bool battLow: (batt && batt.state === 2 && battPct < 20)

    // Clock
    property string timeText: "…"
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            const d = new Date();
            root.timeText = Qt.formatDateTime(d, "HH:mm");
        }
    }

    LazyLoader {
        active: root.enabled

        PanelWindow {
            id: win
            screen: root.screen
            visible: root.barVisible
            color: "transparent"

            // Reserve space like a real bar (Waybar-style).
            // When hidden, release the reserved area.
            exclusiveZone: root.shouldShow ? root.barH : 0

            anchors { left: true; right: true; top: true }
            implicitHeight: root.barH

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusionMode: ExclusionMode.Normal
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            WlrLayershell.namespace: "qs-top-status"

            Item {
                anchors.fill: parent
                transform: Translate { y: root.offsetY }

                // Background strip
                Rectangle {
                    anchors.fill: parent
                    color: colors.panelBg
                    opacity: 0.92
                    border.width: 1
                    border.color: colors.panelBorder
                }

                // Accent line
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: Math.max(1, Math.round(2 * root.scale))
                    color: colors.color1
                    opacity: 0.85
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: root.padX
                    anchors.rightMargin: root.padX
                    spacing: Math.round(14 * root.scale)

                    Item { Layout.fillWidth: true }

                    // Center cluster
                    Rectangle {
                        id: cluster
                        color: colors.panelBg2
                        border.width: 1
                        border.color: colors.panelBorder
                        radius: Math.round(10 * root.scale)
                        opacity: 0.92

                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                        implicitHeight: Math.round(26 * root.scale)
                        implicitWidth: clusterRow.implicitWidth + Math.round(18 * root.scale)

                        RowLayout {
                            id: clusterRow
                            anchors.centerIn: parent
                            spacing: Math.round(12 * root.scale)

                            Text {
                                text: root.timeText
                                color: colors.foreground
                                font.pixelSize: 12 * root.scale
                                font.weight: 850
                                font.family: "JetBrainsMono Nerd Font"
                                font.letterSpacing: 0.6 * root.scale
                            }

                            Rectangle {
                                width: 1
                                height: Math.round(12 * root.scale)
                                color: colors.panelBorder
                                opacity: 0.5
                            }

                            Text {
                                text: root.wifiText
                                color: colors.muted
                                font.pixelSize: 10 * root.scale
                                font.weight: 750
                                font.family: "JetBrainsMono Nerd Font"
                                font.letterSpacing: 0.6 * root.scale
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }

                            Rectangle {
                                visible: colors.isLaptop
                                width: 1
                                height: Math.round(12 * root.scale)
                                color: colors.panelBorder
                                opacity: 0.5
                            }

                            Text {
                                visible: colors.isLaptop
                                text: root.batt ? (root.battPct + "%") : "…"
                                color: root.battLow ? colors.color1 : colors.foreground
                                font.pixelSize: 10 * root.scale
                                font.weight: 850
                                font.family: "JetBrainsMono Nerd Font"
                                font.letterSpacing: 0.6 * root.scale
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }
                }
            }
        }
    }
}
