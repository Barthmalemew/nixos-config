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

	visible: true

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

	readonly property var dev: UPower.displayDevice

	readonly property int pct: dev ? Math.round(dev.percentage) : 100
	readonly property int state: dev ? dev.state : 0 // 0=Unknown, 1=Charging, 2=Discharging
	
	readonly property bool isDischarging: state === 2
	readonly property bool isCharging: state === 1
	readonly property bool isFull: state === 4
	readonly property bool isPlugged: !isDischarging
	
	readonly property bool isLow: isDischarging && pct < 20
	
	readonly property int etaSeconds: isCharging ? dev.timeToFull : dev.timeToEmpty
	readonly property bool showFullEta: isCharging || (isPlugged && dev.timeToFull > 0)
	
	readonly property color accentColor: isLow ? colors.color1 : (isPlugged ? colors.color4 : colors.color2) 
	readonly property string statusLabel: isPlugged ? "EXT_BRIDGE" : (isLow ? "CRITICAL" : "INT_RESERVE")

	function formatTime(seconds) {
		if (seconds <= 0) return "--:--";
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
					}
					Item { Layout.fillWidth: true }
					Text {
						text: win.etaLabel + ": " + win.formatTime(win.etaSeconds)
						color: colors.foreground
						font.pixelSize: 10 * win.scale
						font.weight: 800
						font.letterSpacing: 0.8 * win.scale
						font.wordSpacing: 1 * win.scale
					}
				}

				Row {
					id: railContainer
					Layout.fillWidth: true
					height: 24 * win.scale
					spacing: 1 
					
					Repeater {
						model: 8 
						Shape {
							width: (railContainer.width - 7) / 8
							height: 24 * win.scale
							readonly property bool isActive: (index / 8) < (win.pct / 100)
							
							ShapePath {
								fillColor: isActive ? win.accentColor : colors.emptyRail
								strokeColor: colors.black
								strokeWidth: 1
								startX: 12 * win.scale; startY: 0
								PathLine { x: width; y: 0 }
								PathLine { x: width - (12 * win.scale); y: 24 * win.scale }
								PathLine { x: 0; y: 24 * win.scale }
								PathLine { x: 12 * win.scale; y: 0 }
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
					}
					Item { Layout.fillWidth: true }
					Text {
						text: (win.dev && typeof win.dev.voltage === "number" ? win.dev.voltage.toFixed(1) : "0.0") + "V"
						color: colors.muted
						font.pixelSize: 7 * win.scale
						font.weight: 800
						font.letterSpacing: 0.8 * win.scale
						opacity: 0.5
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
