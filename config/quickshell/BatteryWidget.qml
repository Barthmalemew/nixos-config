import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.UPower

import "theme" as Theme

PanelWindow {
	id: win

	readonly property real scale: colors.scale

	Theme.Colors { id: colors }

	anchors {
		right: true
		bottom: true
	}

	margins { right: 30 * win.scale; bottom: 30 * win.scale }

	color: "transparent"
	
	implicitWidth: 620 * win.scale
	implicitHeight: 120 * win.scale

	WlrLayershell.layer: WlrLayer.Bottom
	WlrLayershell.exclusionMode: ExclusionMode.Ignore
	WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
	WlrLayershell.namespace: "qs-battery-tactical"

	mask: Region { item: content }

	property bool enabled: true
	visible: enabled

	// UPower is the most reliable interface for battery percentage/state and ETA.
	readonly property var dev: UPower.displayDevice

	// Some UPower bindings report percentage as 0..1, others as 0..100.
	readonly property real pctRaw: dev ? dev.percentage : 1.0
	readonly property int pct: dev ? Math.round((pctRaw <= 1.0) ? (pctRaw * 100) : pctRaw) : 100
	readonly property int state: dev ? dev.state : 0 // 0=Unknown, 1=Charging, 2=Discharging, 4=Fully charged
	
	readonly property bool isDischarging: state === 2
	readonly property bool isCharging: state === 1
	readonly property bool isFull: state === 4
	readonly property bool isPlugged: !isDischarging
	
	readonly property bool isLow: isDischarging && pct < 20
	
	readonly property int etaSeconds: isCharging ? (dev ? dev.timeToFull : 0) : (dev ? dev.timeToEmpty : 0)
	readonly property bool showFullEta: isCharging || (isPlugged && (dev ? dev.timeToFull : 0) > 0)
	readonly property string etaLabel: showFullEta ? "ETA_FULL" : "ETA_EMPTY"
	
	readonly property color accentColor: isLow ? colors.color1 : (isPlugged ? colors.color4 : colors.color2) 
	readonly property string statusLabel: isPlugged ? "EXT_BRIDGE" : (isLow ? "CRITICAL" : "INT_RESERVE")

	function formatTime(seconds) {
		if (!seconds || seconds <= 0) return "--:--";
		const h = Math.floor(seconds / 3600);
		const m = Math.floor((seconds % 3600) / 60);
		if (h > 0) return h + "H " + m + "M";
		return m + "M";
	}

	Item {
		id: content
		width: 620 * win.scale
		height: 100 * win.scale
		clip: true

		Shape {
			anchors.fill: parent
			ShapePath {
				fillColor: colors.panelBg
				strokeColor: colors.color1
				strokeWidth: 2
				startX: 50 * win.scale; startY: 0
				PathLine { x: 620 * win.scale; y: 0 }
				PathLine { x: 570 * win.scale; y: 100 * win.scale }
				PathLine { x: 0; y: 100 * win.scale }
				PathLine { x: 50 * win.scale; y: 0 }
			}
		}

		Item {
			id: badge
			width: 110 * win.scale; height: 100 * win.scale
			
			Shape {
				anchors.fill: parent
				opacity: win.isLow ? 1.0 : 0.9
				
				SequentialAnimation on opacity {
					running: win.isLow
					loops: Animation.Infinite
					NumberAnimation { from: 1.0; to: 0.6; duration: 600; easing.type: Easing.InOutQuad }
					NumberAnimation { from: 0.6; to: 1.0; duration: 600; easing.type: Easing.InOutQuad }
				}

				ShapePath {
					fillColor: colors.color1
					strokeWidth: 0
					startX: 50 * win.scale; startY: 0
					PathLine { x: 110 * win.scale; y: 0 }
					PathLine { x: 110 * win.scale; y: 100 * win.scale }
					PathLine { x: 0; y: 100 * win.scale }
					PathLine { x: 50 * win.scale; y: 0 }
				}
			}

			Text {
				anchors.centerIn: parent
				anchors.verticalCenterOffset: 10 * win.scale
				anchors.horizontalCenterOffset: 10 * win.scale
				text: "02"
				color: colors.black
				font.pixelSize: 38 * win.scale
				font.weight: 950
				font.family: "JetBrainsMono Nerd Font"
			}
		}

		RowLayout {
			anchors.left: badge.right
			anchors.right: parent.right
			anchors.top: parent.top
			anchors.bottom: parent.bottom
			anchors.leftMargin: 20 * win.scale
			anchors.rightMargin: 75 * win.scale
			anchors.topMargin: 10 * win.scale
			anchors.bottomMargin: 10 * win.scale
			spacing: 20 * win.scale

			Column {
				Layout.alignment: Qt.AlignVCenter
				spacing: -8 * win.scale
				Text {
					text: win.pct + "%"
					color: win.accentColor
					font.pixelSize: 52 * win.scale
					font.weight: 950
					font.family: "JetBrainsMono Nerd Font"
				}
				Text {
					text: (dev && dev.present) ? "RESERVE" : "STATIONARY"
					color: win.accentColor
					font.pixelSize: 10 * win.scale
					font.weight: 900
					opacity: 0.8
					anchors.horizontalCenter: parent.horizontalCenter
				}
			}

			Rectangle {
				width: 3 * win.scale; height: 60 * win.scale
				color: win.accentColor
				opacity: 0.3
			}

			ColumnLayout {
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignVCenter
				spacing: 6 * win.scale

				RowLayout {
					Layout.fillWidth: true
					Text {
						text: "STATUS // " + win.statusLabel
						color: win.accentColor
						font.pixelSize: 11 * win.scale
						font.weight: 950
						font.letterSpacing: 1.4 * win.scale
						font.wordSpacing: 1 * win.scale
						elide: Text.ElideRight
						Layout.fillWidth: true
					}
					Text {
						text: win.etaLabel + ": " + win.formatTime(win.etaSeconds)
						color: colors.foreground
						font.pixelSize: 10 * win.scale
						font.weight: 800
						font.letterSpacing: 0.8 * win.scale
						font.wordSpacing: 1 * win.scale
						horizontalAlignment: Text.AlignRight
						elide: Text.ElideLeft
						Layout.preferredWidth: 160 * win.scale
						Layout.maximumWidth: 200 * win.scale
					}
				}

				Row {
					id: railContainer
					Layout.fillWidth: true
					height: 24 * win.scale
					spacing: 1 
					clip: true
					
					Repeater {
						model: 8 
						Shape {
							id: rail
							width: Math.max(1, (railContainer.width - 7) / 8)
							height: 24 * win.scale
							readonly property bool isActive: (index / 8) < (win.pct / 100)
							readonly property real cut: Math.min(12 * win.scale, width)
							
							ShapePath {
								fillColor: isActive ? win.accentColor : colors.emptyRail
								strokeColor: colors.black
								strokeWidth: 1
								startX: rail.cut; startY: 0
								PathLine { x: width; y: 0 }
								PathLine { x: width - rail.cut; y: 24 * win.scale }
								PathLine { x: 0; y: 24 * win.scale }
								PathLine { x: rail.cut; y: 0 }
							}
						}
					}
				}

				RowLayout {
					Layout.fillWidth: true
					Text {
						text: "EVA_UNIT_02 // MAGI_POWER_MGMT // REV_12"
						color: colors.muted
						font.pixelSize: 7 * win.scale
						font.weight: 800
						font.letterSpacing: 0.8 * win.scale
						font.wordSpacing: 1 * win.scale
						opacity: 0.5
						elide: Text.ElideRight
						Layout.fillWidth: true
					}
					Text {
						text: ((win.dev && typeof win.dev.voltage === "number") ? win.dev.voltage.toFixed(1) : "0.0") + "V"
						color: colors.muted
						font.pixelSize: 7 * win.scale
						font.weight: 800
						font.letterSpacing: 0.8 * win.scale
						opacity: 0.5
						horizontalAlignment: Text.AlignRight
						Layout.preferredWidth: 70 * win.scale
					}
				}
			}
		}
		
		Repeater {
			model: 2
			Rectangle {
				width: 4 * win.scale; height: 4 * win.scale
				radius: 2 * win.scale
				color: win.accentColor
				opacity: 0.6
				x: index == 0 ? (12 * win.scale) : (595 * win.scale)
				y: index == 0 ? (82 * win.scale) : (12 * win.scale)
			}
		}
	}
}
