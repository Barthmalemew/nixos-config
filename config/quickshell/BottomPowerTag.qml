import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland

import "theme" as Theme

PanelWindow {
	id: win

	property var screen
	property bool enabled: true
	visible: enabled
	screen: win.screen

	Theme.Colors { id: colors }

	readonly property real scale: colors.scale

	anchors {
		bottom: true
		left: true
		right: true
	}

	color: "transparent"
	implicitHeight: 300 * win.scale

	WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.exclusionMode: ExclusionMode.Ignore
	WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
	WlrLayershell.namespace: "qs-power-tag"

	mask: Region {
		Region { item: trigger }
		Region { item: container }
	}

	Theme.PowerMenu {
		id: powerMenu
		screenInfo: win.screen
	}

	property bool isHovered: false
	property bool isDragging: false
	property real dragY: 0

	Item {
		id: trigger
		width: 140 * win.scale
		height: 30 * win.scale
		anchors.bottom: parent.bottom
		anchors.horizontalCenter: parent.horizontalCenter
		z: 10

		HoverHandler {
			onHoveredChanged: {
				if (hovered) {
					win.isHovered = true;
					hideTimer.stop();
				} else if (!win.isDragging) {
					hideTimer.restart();
				}
			}
		}
	}

	Timer {
		id: hideTimer
		interval: 1000
		onTriggered: win.isHovered = false
	}

	Item {
		id: container
		width: 130 * win.scale
		height: 40 * win.scale
		anchors.horizontalCenter: parent.horizontalCenter
		
		readonly property real idleY: win.height + (20 * win.scale)
		readonly property real hoveredY: win.height - height - (15 * win.scale)
		
		y: (win.isDragging || win.isHovered) ? (hoveredY - win.dragY) : idleY
		opacity: (win.isDragging || win.isHovered) ? 1.0 : 0.0

		Behavior on y { 
			id: yBehavior
			enabled: !win.isDragging 
			SpringAnimation { spring: 2.5; damping: 0.3; epsilon: 0.01; velocity: 1500 } 
		}
		
		Behavior on opacity { NumberAnimation { duration: 250 } }

		Shape {
			anchors.fill: parent
			ShapePath {
				fillColor: colors.panelBg
				strokeColor: colors.color1
				strokeWidth: 2
				startX: 15 * win.scale; startY: 0
				PathLine { x: 115 * win.scale; y: 0 }
				PathLine { x: 130 * win.scale; y: 20 * win.scale }
				PathLine { x: 130 * win.scale; y: 40 * win.scale }
				PathLine { x: 0; y: 40 * win.scale }
				PathLine { x: 0; y: 20 * win.scale }
				PathLine { x: 15 * win.scale; y: 0 }
			}
		}

		Text {
			anchors.centerIn: parent
			anchors.verticalCenterOffset: 4 * win.scale
			text: "POWER"
			color: colors.color1
			font.pixelSize: 11 * win.scale
			font.weight: 950
			font.family: "JetBrainsMono Nerd Font"
			font.letterSpacing: 2 * win.scale
		}

		MouseArea {
			anchors.fill: parent
			cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
			
			property real pressY: 0
			property real dragThreshold: 120 * win.scale

			onPressed: mouse => {
				pressY = mouse.y;
				win.isDragging = true;
				hideTimer.stop();
			}

			onPositionChanged: mouse => {
				if (!win.isDragging) return;
				const deltaY = pressY - mouse.y;
				if (deltaY > 0) {
					win.dragY = deltaY;
				} else {
					win.dragY = 0;
				}
				if (deltaY > dragThreshold) {
					powerMenu.shouldShow = true;
					win.isDragging = false;
					win.isHovered = false;
					win.dragY = 0;
				}
			}

			onReleased: {
				win.isDragging = false;
				if (!trigger.containsMouse) hideTimer.restart();
			}
		}
	}
}
