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
	
	property bool enabled: true

	readonly property real scale: colors.scale
	readonly property int osdW: Math.round(68 * scale)
	readonly property int osdH: Math.round(176 * scale)

	readonly property var node: Pipewire.defaultAudioSink
	readonly property real volume: node ? node.audio.volume : 0
	readonly property bool muted: node ? node.audio.muted : true

	property real displayedVolume: volume
	property int displayedPercent: Math.round(displayedVolume * 100)
	property bool adjusting: false
	property bool shouldShowOsd: false
	property bool osdVisible: false
	property real offsetX: 0

	function iconFor(vol, isMuted) {
		if (isMuted) return "󰝟";
		if (vol <= 0) return "󰝟";
		if (vol < 0.33) return "󰕿";
		if (vol < 0.66) return "󰖀";
		return "󰕾";
	}

	function setVolumeFromRatio(ratio) {
		const r = Math.max(0, Math.min(1.0, ratio));
		displayedVolume = r;
		// Set via wpctl for reliability (Pipewire service objects can be read-only).
		setVolProc.exec([colors.wpctlBin, "set-volume", "-l", "1", "@DEFAULT_AUDIO_SINK@", Math.round(r * 100) + "%"]);
	}

	Process { id: setVolProc }

	function setVolumeFromY(y, barHeight) {
		if (barHeight <= 0) return;
		const ratio = 1 - (y / barHeight);
		setVolumeFromRatio(ratio);
	}

	function showOsd() {
		osdVisible = true;
		shouldShowOsd = true;
		offsetX = osdW + Math.round(30 * scale);
		Qt.callLater(() => { root.offsetX = 0; });
		osdTimer.restart();
	}

	function hideOsd() {
		shouldShowOsd = false;
		offsetX = osdW + Math.round(30 * scale);
		hideKick.restart();
	}

	onVolumeChanged: {
		if (!adjusting) {
			displayedVolume = volume;
			showOsd();
		}
	}

	onMutedChanged: showOsd()

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
		WlrLayershell.namespace: "qs-volume-osd"

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
				color: root.muted ? colors.muted : colors.color1
				opacity: 0.9
			}

			ColumnLayout {
				anchors.fill: parent
				anchors.margins: Math.round(10 * scale)
				spacing: Math.round(8 * scale)

				Text {
					Layout.alignment: Qt.AlignHCenter
					text: root.iconFor(root.displayedVolume, root.muted)
					color: root.muted ? colors.muted : colors.color1
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
							height: Math.max(0, Math.min(bar.height - 2, Math.round((bar.height - 2) * Math.min(1, Math.max(0, root.displayedVolume)))))
							radius: 999
							color: root.muted ? colors.muted : colors.color1
						}
					}

					MouseArea {
						anchors.fill: parent
						onPressed: {
							root.adjusting = true;
							root.setVolumeFromY(mouse.y, bar.height);
						}
						onPositionChanged: {
							if (!pressed) return
							root.setVolumeFromY(mouse.y, bar.height)
						}
						onReleased: root.adjusting = false
					}
				}

				Text {
					Layout.alignment: Qt.AlignHCenter
					text: root.muted ? "M" : String(root.displayedPercent)
					color: root.muted ? colors.muted : colors.color1
					font.pixelSize: 10 * scale
					font.weight: 950
					font.family: "JetBrainsMono Nerd Font"
				}
			}
		}
	}
}
