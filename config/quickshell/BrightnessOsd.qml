import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

import "theme" as Theme

Scope {
	id: root

	required property var modelData
	readonly property var screen: modelData
	property bool isMain: false

	Theme.Colors { id: colors }
	
	property bool enabled: true

	readonly property real scale: colors.scale
	readonly property int osdW: Math.round(68 * scale)
	readonly property int osdH: Math.round(176 * scale)

	property string backlightDevice: ""
	property int brightness: 0
	property int maxBrightness: 1
	property real displayedPercent: maxBrightness > 0 ? (brightness / maxBrightness * 100) : 0
	
	property bool adjusting: false
	property bool shouldShowOsd: false
	property bool osdVisible: false
	property real offsetX: 0

	Process {
		id: findBacklight
		command: ["sh", "-c", "ls -1 /sys/class/backlight | head -n1"]
		stdout: SplitParser {
			onRead: data => {
				const name = (data || "").trim();
				if (name) root.backlightDevice = "/sys/class/backlight/" + name;
			}
		}
	}

	Component.onCompleted: findBacklight.running = true

	Timer {
		id: updateTimer
		interval: root.osdVisible ? 200 : 2000
		running: root.backlightDevice.length > 0
		repeat: true
		triggeredOnStart: true
		onTriggered: {
			brightnessFile.reload()
			maxBrightnessFile.reload()
		}
	}

	FileView {
		id: brightnessFile
		path: root.backlightDevice ? (root.backlightDevice + "/brightness") : ""
		onLoaded: root.brightness = parseInt(text().trim())
	}

	FileView {
		id: maxBrightnessFile
		path: root.backlightDevice ? (root.backlightDevice + "/max_brightness") : ""
		onLoaded: root.maxBrightness = parseInt(text().trim())
	}

	function setBrightnessPercent(pct) {
		if (!root.backlightDevice) return;
		const val = Math.round((pct / 100) * maxBrightness);
		setBrightness.command = ["sh", "-c", "echo " + val + " | tee " + root.backlightDevice + "/brightness"];
		setBrightness.running = true;
	}

	Process { id: setBrightness }

	function showOsd() {
		osdVisible = true;
		shouldShowOsd = true;
		offsetX = osdW + Math.round(30 * scale);
		brightnessFile.reload();
		maxBrightnessFile.reload();
		Qt.callLater(() => { root.offsetX = 0; });
		osdTimer.restart();
	}

	function hideOsd() {
		shouldShowOsd = false;
		offsetX = osdW + Math.round(30 * scale);
		hideKick.restart();
	}

	onBrightnessChanged: {
		if (!adjusting) {
			showOsd();
		}
	}

	Timer {
		id: osdTimer
		interval: 2500
		onTriggered: root.hideOsd()
	}

	Timer {
		id: hideKick
		interval: 160
		repeat: false
		onTriggered: root.osdVisible = false
	}

	Behavior on offsetX {
		NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
	}

	PanelWindow {
			screen: root.screen
			visible: root.osdVisible && root.isMain && root.enabled
			exclusiveZone: 0

			anchors.right: true
			anchors.top: true
			margins.right: Math.round(18 * scale)
			margins.top: {
				const s = root.screen;
				const h = (s && s.geometry && s.geometry.height) ? s.geometry.height : (s && s.height ? s.height : 1080);
				return Math.max(0, Math.round((h - root.osdH) / 2));
			}

			readonly property real scale: colors.scale

			WlrLayershell.layer: WlrLayer.Overlay
			WlrLayershell.exclusionMode: ExclusionMode.Ignore
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
			WlrLayershell.namespace: "qs-brightness-osd"

			focusable: false
			color: "transparent"
			mask: Region {}

			implicitWidth: root.osdW
			implicitHeight: root.osdH

			Item {
				anchors.fill: parent
				transform: Translate { x: root.offsetX }

				Rectangle {
					anchors.fill: parent
					radius: 999
					color: colors.panelBg
					border.width: 1
					border.color: colors.panelBorder
					opacity: 0.96
				}

				Rectangle {
					anchors.left: parent.left
					anchors.top: parent.top
					anchors.bottom: parent.bottom
					width: Math.max(2, Math.round(3 * scale))
					color: colors.color2
					opacity: 0.9
				}

				ColumnLayout {
					anchors.fill: parent
					anchors.margins: Math.round(10 * scale)
					spacing: Math.round(8 * scale)

					Text {
						Layout.alignment: Qt.AlignHCenter
						text: "󰃠"
						color: colors.color2
						font.pixelSize: 16 * scale
						font.family: "JetBrainsMono Nerd Font"
						font.weight: 950
					}

					Rectangle {
						id: bar
						Layout.alignment: Qt.AlignHCenter
						implicitWidth: Math.round(10 * scale)
						Layout.fillHeight: true
						radius: 999
						clip: true
						color: colors.panelBg2
						border.color: colors.panelBorder
						border.width: 1

						Item {
							anchors.fill: parent
							clip: true
							Rectangle {
								anchors.left: parent.left
								anchors.right: parent.right
								anchors.bottom: parent.bottom
								anchors.margins: 1
								height: Math.max(0, Math.min(bar.height - 2, Math.round((bar.height - 2) * Math.min(1, Math.max(0, root.displayedPercent / 100)))))
								radius: 999
								color: colors.color2
							}
						}

						MouseArea {
							anchors.fill: parent
							onPressed: {
								root.adjusting = true;
								root.setBrightnessPercent((1 - (mouse.y / bar.height)) * 100);
							}
							onPositionChanged: {
								if (!pressed) return
								root.setBrightnessPercent((1 - (mouse.y / bar.height)) * 100)
							}
							onReleased: root.adjusting = false
						}
					}

					Text {
						Layout.alignment: Qt.AlignHCenter
						text: root.backlightDevice.length > 0 ? String(Math.round(root.displayedPercent)) : "OFF"
						color: colors.color2
						font.pixelSize: 10 * scale
						font.weight: 950
						font.family: "JetBrainsMono Nerd Font"
					}
				}
			}
		}
}
