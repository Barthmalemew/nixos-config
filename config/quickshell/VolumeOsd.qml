import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Pipewire

import "theme" as Theme

Scope {
	id: root

	required property var modelData
	readonly property var screen: modelData
	property bool isMain: false

	Theme.Colors { id: colors }

	readonly property var node: Pipewire.defaultAudioSink
	readonly property real volume: node ? node.audio.volume : 0
	readonly property bool muted: node ? node.audio.muted : true

	property real displayedVolume: volume
	property int displayedPercent: Math.round(displayedVolume * 100)
	property bool adjusting: false
	property bool shouldShowOsd: false

	function iconFor(vol, isMuted) {
		if (isMuted) return "󰝟";
		if (vol <= 0) return "󰝟";
		if (vol < 0.33) return "󰕿";
		if (vol < 0.66) return "󰖀";
		return "󰕾";
	}

	function setVolumeFromRatio(ratio) {
		if (node) {
			node.audio.volume = Math.max(0, Math.min(1.0, ratio));
		}
	}

	onVolumeChanged: {
		if (!adjusting) {
			displayedVolume = volume;
			shouldShowOsd = true;
			osdTimer.restart();
		}
	}

	onMutedChanged: {
		shouldShowOsd = true;
		osdTimer.restart();
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
			
			// Resilient Geometry Access
			margins.top: (screen ? (screen.geometry ? screen.geometry.height : screen.height) : 1080) / 9

			// Resilient Scale Calculation
			readonly property real scale: (screen ? (screen.geometry ? screen.geometry.height : screen.height) : 1080) / 1080

			WlrLayershell.layer: WlrLayer.Overlay
			WlrLayershell.exclusionMode: ExclusionMode.Ignore
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
			WlrLayershell.namespace: "qs-volume-osd"

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
						strokeColor: colors.color1
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
						text: root.iconFor(root.displayedVolume, root.muted)
						color: root.muted ? colors.muted : colors.color1
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
									fillColor: root.muted ? colors.muted : colors.color1
									startX: 6 * scale; startY: 0
									PathLine { x: (bar.width * root.displayedVolume); y: 0 }
									PathLine { x: (bar.width * root.displayedVolume) - (6 * scale); y: 12 * scale }
									PathLine { x: 0; y: 12 * scale }
									PathLine { x: 6 * scale; y: 0 }
								}
							}
						}

						MouseArea {
							anchors.fill: parent
							onPressed: {
								root.adjusting = true;
								root.setVolumeFromRatio(mouse.x / bar.width);
							}
							onPositionChanged: {
								if (!pressed) return
								root.setVolumeFromRatio(mouse.x / bar.width)
							}
							onReleased: root.adjusting = false
						}
					}

					Text {
						text: root.muted ? "MUTED" : (root.displayedPercent + "%")
						color: colors.color1
						font.pixelSize: 18 * scale
						font.weight: 950
						font.family: "JetBrainsMono Nerd Font"
						Layout.minimumWidth: 60 * scale
					}
				}

				Text {
					text: "AUDIO_OUTPUT // ANALOG_LINK"
					color: colors.color1
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
