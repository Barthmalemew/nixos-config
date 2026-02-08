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

	readonly property real scale: colors.scale

	property string backlightDevice: ""
	property int brightness: 0
	property int maxBrightness: 1
	property real displayedPercent: maxBrightness > 0 ? (brightness / maxBrightness * 100) : 0
	
	property bool adjusting: false
	property bool shouldShowOsd: false

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
		interval: 2000
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

	onBrightnessChanged: {
		if (!adjusting) {
			shouldShowOsd = true;
			osdTimer.restart();
		}
	}

	Timer {
		id: osdTimer
		interval: 2500
		onTriggered: root.shouldShowOsd = false
	}

	LazyLoader {
		active: root.shouldShowOsd && root.isMain

		PanelWindow {
			screen: root.screen
			visible: root.shouldShowOsd && root.isMain
			exclusiveZone: 0

			anchors.top: true
			margins.top: (1080 * scale) / 9

			readonly property real scale: colors.scale

			WlrLayershell.layer: WlrLayer.Overlay
			WlrLayershell.exclusionMode: ExclusionMode.Ignore
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
			WlrLayershell.namespace: "qs-brightness-osd"

			focusable: false
			color: "transparent"
			mask: Region {}

			implicitWidth: 550 * scale
			implicitHeight: 60 * scale

			Item {
				anchors.fill: parent

				Shape {
					anchors.fill: parent
					ShapePath {
						fillColor: colors.panelBg
						strokeColor: colors.color2
						strokeWidth: 2
						startX: 30 * scale; startY: 0
						PathLine { x: 550 * scale; y: 0 }
						PathLine { x: 520 * scale; y: 60 * scale }
						PathLine { x: 0; y: 60 * scale }
						PathLine { x: 30 * scale; y: 0 }
					}
				}

				RowLayout {
					anchors.fill: parent
					anchors.leftMargin: 45 * scale
					anchors.rightMargin: 45 * scale
					spacing: 15 * scale

					Text {
						text: "󰃠"
						color: colors.color2
						font.pixelSize: 22 * scale
						font.family: "JetBrainsMono Nerd Font"
						font.weight: 950
					}

					Rectangle {
						id: bar
						Layout.fillWidth: true
						implicitHeight: 12 * scale
						color: colors.panelBg2
						border.color: colors.panelBorder
						border.width: 1

						Item {
							anchors.fill: parent
							clip: true
							Shape {
								anchors.fill: parent
								ShapePath {
									fillColor: colors.color2
									startX: 6 * scale; startY: 0
									PathLine { x: (bar.width * (root.displayedPercent / 100)); y: 0 }
									PathLine { x: (bar.width * (root.displayedPercent / 100)) - (6 * scale); y: 12 * scale }
									PathLine { x: 0; y: 12 * scale }
									PathLine { x: 6 * scale; y: 0 }
								}
							}
						}

						MouseArea {
							anchors.fill: parent
							onPressed: {
								root.adjusting = true;
								root.setBrightnessPercent((mouse.x / bar.width) * 100);
							}
							onPositionChanged: {
								if (!pressed) return
								root.setBrightnessPercent((mouse.x / bar.width) * 100)
							}
							onReleased: root.adjusting = false
						}
					}

					Text {
						text: root.backlightDevice.length > 0 ? (Math.round(root.displayedPercent) + "%") : "OFF"
						color: colors.color2
						font.pixelSize: 18 * scale
						font.weight: 950
						font.family: "JetBrainsMono Nerd Font"
						Layout.minimumWidth: 60 * scale
					}
				}

				Text {
					text: "OPTIC_LINK // BACKLIGHT_LEVEL"
					color: colors.color2
					font.pixelSize: 8 * scale
					font.weight: 900
					opacity: 0.5
					anchors.bottom: parent.top
					anchors.left: parent.left
					anchors.leftMargin: 35 * scale
					anchors.bottomMargin: 2 * scale
				}
			}
		}
	}
}
