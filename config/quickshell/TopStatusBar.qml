import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import "theme" as Theme

Scope {
    id: root

    property var screen

    Theme.Colors { id: colors }
    readonly property real scale: colors.scale

    readonly property int barH: Math.round(36 * scale)
    readonly property int padX: Math.round(18 * scale)

    // Visibility is driven by NiriActivity
    property bool shouldShow: false
    property real offsetY: 0

    Timer {
        id: hideKick
        interval: 260
        repeat: false
        onTriggered: win.visible = false
    }

    Behavior on offsetY {
        NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
    }

    onShouldShowChanged: {
        if (shouldShow) {
            hideKick.stop();
            win.visible = true;
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
        active: true
        onHasWindowsChanged: root.shouldShow = niri.hasWindows
        Component.onCompleted: root.shouldShow = niri.hasWindows
    }

    // Network (nmcli)
    property string netText: "…"

    Process {
        id: nmcli
        command: [colors.nmcliBin, "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "dev", "status"]
        stdout: SplitParser {
            onRead: data => {
                const lines = (data || "").trim().split("\n");
                let wifiName = "";
                let wired = false;
                for (let i = 0; i < lines.length; i++) {
                    const parts = lines[i].split(":");
                    if (parts.length < 4) continue;
                    const type = parts[1];
                    const state = parts[2];
                    const conn = parts.slice(3).join(":");
                    if (state !== "connected") continue;
                    if (type === "wifi") wifiName = conn;
                    if (type === "ethernet") wired = true;
                }
                if (wifiName && wifiName.length > 0) root.netText = wifiName;
                else if (wired) root.netText = "Wired";
                else root.netText = "Offline";
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

    // Battery (re-use existing monitor)
    BatteryMonitor { id: batt }

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
        active: true

        PanelWindow {
            id: win
            screen: root.screen
            visible: false
            color: "transparent"

            anchors { left: true; right: true; top: true }
            height: root.barH

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

                    // Left: time
                    Text {
                        text: root.timeText
                        color: colors.foreground
                        font.pixelSize: 13 * root.scale
                        font.weight: 800
                        font.family: "JetBrainsMono Nerd Font"
                        font.letterSpacing: 0.8 * root.scale
                    }

                    // Mid: network
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "NET // " + root.netText.toUpperCase()
                        color: colors.muted
                        font.pixelSize: 10 * root.scale
                        font.weight: 700
                        font.family: "JetBrainsMono Nerd Font"
                        font.letterSpacing: 1.0 * root.scale
                        elide: Text.ElideRight
                    }
                    Item { Layout.fillWidth: true }

                    // Right: battery
                    Text {
                        visible: colors.isLaptop
                        text: (batt.present ? ("PWR // " + batt.capacity + "%") : "PWR // …")
                        color: batt.present && batt.capacity <= 20 && batt.status === "Discharging" ? colors.color1 : colors.foreground
                        font.pixelSize: 10 * root.scale
                        font.weight: 800
                        font.family: "JetBrainsMono Nerd Font"
                        font.letterSpacing: 1.0 * root.scale
                    }
                }
            }
        }
    }
}
