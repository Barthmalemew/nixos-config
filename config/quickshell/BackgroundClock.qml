import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import "theme" as Theme

PanelWindow {
	id: win

	visible: true

	color: "transparent"

	anchors {
		top: true
		bottom: true
		left: true
		right: true
	}

	focusable: false

	WlrLayershell.layer: WlrLayer.Bottom
	WlrLayershell.exclusionMode: ExclusionMode.Ignore
	WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
	WlrLayershell.namespace: "qs-bg-clock"

	Theme.Colors { id: colors }
	
	property url foregroundMaskSource: "assets/unit2-foreground.png"
	property url asukaSource: "assets/asuka.png"

	// Resilient Scale Calculation (Supports v0.1.0 and v0.2.1)
	readonly property real scale: (win.screen ? (win.screen.geometry ? win.screen.geometry.height : win.screen.height) : 1080) / 1080

	SystemClock {
		id: clock
		precision: SystemClock.Minutes
	}

	Image {
		id: asuka
		source: win.asukaSource
		width: 120 * win.scale
		height: 120 * win.scale
		fillMode: Image.PreserveAspectFit
		anchors.right: parent.right
		anchors.rightMargin: parent.width * 0.20
		y: 60 * win.scale
		z: 5 // Moved behind foregroundMask (z:10)
		smooth: true
		visible: foregroundMask.status === Image.Ready
	}

	Item {
		id: clockAssembly
		x: 40 * win.scale; y: 40 * win.scale
		width: 1400 * win.scale
		height: 600 * win.scale
		z: 1

		Item {
			id: railContainer
			width: 40 * win.scale; height: 450 * win.scale
			anchors.left: parent.left
			anchors.top: parent.top
			anchors.topMargin: 30 * win.scale

			Rectangle {
				id: syncStrip
				width: 4 * win.scale; height: parent.height
				color: colors.color1
				anchors.right: parent.right
			}

			Repeater {
				model: 10
				Rectangle {
					width: index % 5 == 0 ? (15 * win.scale) : (8 * win.scale)
					height: 2 * win.scale
					color: colors.color1
					anchors.right: syncStrip.left
					anchors.rightMargin: 4 * win.scale
					y: (parent.height / 10) * index
				}
			}
		}

		ColumnLayout {
			anchors.left: railContainer.right
			anchors.leftMargin: 15 * win.scale
			anchors.top: railContainer.top
			anchors.topMargin: -80 * win.scale
			spacing: -60 * win.scale

			Text {
				id: timeDisplay
				text: clock.date.toLocaleString(Qt.locale("en_US"), "h:mm")
				color: colors.color1
				font.pixelSize: 360 * win.scale
				font.weight: 950
				font.family: "JetBrainsMono Nerd Font"
				font.letterSpacing: -22 * win.scale
				Layout.leftMargin: -10 * win.scale
			}

			RowLayout {
				Layout.leftMargin: 10 * win.scale
				spacing: 40 * win.scale

				Item {
					width: 50 * win.scale; height: 100 * win.scale
					Layout.alignment: Qt.AlignVCenter
					Text {
						anchors.centerIn: parent
						text: clock.date.toLocaleString(Qt.locale("en_US"), "ddd").toUpperCase()
						color: colors.color2
						font.pixelSize: 68 * win.scale
						font.weight: 950
						font.family: "JetBrainsMono Nerd Font"
						rotation: -90
						transformOrigin: Item.Center
					}
				}

				Column {
					spacing: 2 * win.scale
					Text {
						text: clock.date.toLocaleString(Qt.locale("en_US"), "MMMM dd").toUpperCase()
						color: colors.color2
						font.pixelSize: 32 * win.scale
						font.weight: 950
						font.letterSpacing: 4 * win.scale
						font.family: "JetBrainsMono Nerd Font"
					}
					
					Row {
						spacing: 12 * win.scale
						Text {
							text: "SYNC_RATIO: 99.8%"
							color: colors.color4
							font.pixelSize: 10 * win.scale
							font.weight: 900
							font.letterSpacing: 1.5 * win.scale
						}
						Text {
							text: "PRIORITY_LEVEL: A"
							color: colors.color1
							font.pixelSize: 10 * win.scale
							font.weight: 900
							font.letterSpacing: 1.5 * win.scale
						}
					}

					Rectangle {
						width: 300 * win.scale; height: 6 * win.scale
						color: colors.color1
						opacity: 0.9
						
						Text {
							anchors.right: parent.right
							anchors.rightMargin: 10 * win.scale
							anchors.verticalCenter: parent.verticalCenter
							text: "MAGI_SYSTEM_ACTIVE"
							color: colors.black
							font.pixelSize: 5 * win.scale
							font.weight: 950
						}
					}
				}
			}
		}

		Column {
			anchors.left: parent.left
			anchors.top: parent.top
			spacing: 2 * win.scale
			Text {
				text: "MAGI_02 // SYSTEM_LOG_EXT_ID: " + (clock.date.getTime() % 1000000)
				color: colors.color1
				font.pixelSize: 10 * win.scale
				font.weight: 950
				opacity: 0.8
			}
			Rectangle { width: 120 * win.scale; height: 1 * win.scale; color: colors.color1; opacity: 0.4 }
		}
	}

	Image {
		id: foregroundMask
		anchors.fill: win.contentItem
		source: win.foregroundMaskSource
		fillMode: Image.PreserveAspectCrop
		asynchronous: true
		cache: true
		smooth: true
		z: 10
		visible: status === Image.Ready
	}
}
