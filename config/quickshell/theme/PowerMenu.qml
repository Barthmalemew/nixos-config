import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import "." as Theme

Scope {
	id: root

	property var screenInfo
	property bool shouldShow: false

	Theme.Colors { id: colors }

	// Resolution Scaling Factor (Base 1080p)
	readonly property real scale: colors.scale

	readonly property string loginctlBin: "/run/current-system/sw/bin/loginctl"
	readonly property string systemctlBin: "/run/current-system/sw/bin/systemctl"

	Process {
		id: powerProc
		stdout: SplitParser {
			onRead: data => console.warn("power menu stdout: " + data)
		}
		stderr: SplitParser {
			onRead: data => console.warn("power menu stderr: " + data)
		}
		onExited: (code, status) => {
			console.warn("power menu exit: " + code + " status " + status)
		}
	}

	function close() {
		root.shouldShow = false;
	}

	function runAction(kind) {
		root.close();
		if (kind === "poweroff") powerProc.exec([root.systemctlBin, "poweroff"]);
		else if (kind === "reboot") powerProc.exec([root.systemctlBin, "reboot"]);
		else if (kind === "logout") powerProc.exec([root.loginctlBin, "terminate-session", "self"]);
	}

	// Tactical Transition: slide in from left
	property real optionsOffsetX: 0
	Timer {
		id: openKick
		interval: 1
		repeat: false
		onTriggered: root.optionsOffsetX = 0
	}

	Behavior on optionsOffsetX {
		NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
	}

	onShouldShowChanged: {
		if (shouldShow) {
			optionsOffsetX = -400;
			openKick.restart();
		}
	}

	LazyLoader {
		active: true

		PanelWindow {
			screen: root.screenInfo
			visible: root.shouldShow
			color: "transparent"

			anchors { left: true; right: true; top: true; bottom: true }

			WlrLayershell.layer: WlrLayer.Overlay
			WlrLayershell.exclusionMode: ExclusionMode.Normal
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
			WlrLayershell.namespace: "qs-tactical-power"

			// Dark overlay for dimming
			Rectangle {
				anchors.fill: parent
				color: colors.launcherOverlay
				opacity: root.shouldShow ? 1 : 0
				Behavior on opacity { NumberAnimation { duration: 250 } }
			}

			FocusScope {
				anchors.fill: parent
				focus: true

				MouseArea {
					anchors.fill: parent
					onClicked: root.close()
				}

				Keys.onPressed: (event) => {
					if (event.key === Qt.Key_Escape) {
						root.close();
						event.accepted = true;
					}
				}

				Component.onCompleted: forceActiveFocus()

				Item {
					id: powerOptionsContainer
					property int panelPaddingX: 34 * root.scale
					property int panelPaddingY: 30 * root.scale
					width: optionsColumn.implicitWidth + panelPaddingX * 2
					height: optionsColumn.implicitHeight + panelPaddingY * 2
					anchors.left: parent.left
					anchors.leftMargin: Math.round(parent.width * 0.1)
					anchors.verticalCenter: parent.verticalCenter
					transform: Translate { x: root.optionsOffsetX }

					ColumnLayout {
						id: optionsColumn
						anchors.left: parent.left
						anchors.top: parent.top
						anchors.leftMargin: powerOptionsContainer.panelPaddingX
						anchors.topMargin: powerOptionsContainer.panelPaddingY
						spacing: 25 * root.scale

						// Header Badge
						Item {
							Layout.preferredWidth: 400 * root.scale
							Layout.preferredHeight: 60 * root.scale
							
							Shape {
								anchors.fill: parent
								ShapePath {
									fillColor: colors.color1 // Red
									startX: 30 * root.scale; startY: 0
									PathLine { x: 400 * root.scale; y: 0 }
									PathLine { x: 370 * root.scale; y: 60 * root.scale }
									PathLine { x: 0; y: 60 * root.scale }
									PathLine { x: 30 * root.scale; y: 0 }
								}

								layer.enabled: true
								opacity: 0.9
							}
							
							Text {
								anchors.centerIn: parent
								text: "TACTICAL_OVERRIDE // SYSTEM_EXIT"
								color: colors.black
								font.pixelSize: 16 * root.scale
								font.weight: 950
								font.letterSpacing: 1.6 * root.scale
								font.wordSpacing: 1.2 * root.scale
								font.family: "JetBrainsMono Nerd Font"
							}
						}

						Rectangle {
							Layout.fillWidth: true
							Layout.preferredHeight: 1
							color: colors.panelBorder
							opacity: 0.3
						}

						PowerOption {
							label: "Power Off"
							subtext: "TERMINATE_SYSTEM_CORE"
							action: "poweroff"
						}

						PowerOption {
							label: "Reboot"
							subtext: "INITIALIZE_SYSTEM_WARM_START"
							action: "reboot"
						}

						PowerOption {
							label: "Logout"
							subtext: "SUSPEND_CURRENT_SESSION"
							action: "logout"
						}

						Item { Layout.preferredHeight: 10 * root.scale }

						// Cancel option
						Item {
							id: cancelItem
							Layout.preferredWidth: 200 * root.scale
							Layout.preferredHeight: 36 * root.scale
							Layout.leftMargin: 50 * root.scale
							property bool hovered: false

							MouseArea {
								id: cancelArea
								anchors.fill: parent
								hoverEnabled: true
								onEntered: parent.hovered = true
								onExited: parent.hovered = false
								onClicked: root.close()
							}

							Shape {
								anchors.fill: parent
								ShapePath {
									fillColor: "transparent"
									strokeColor: cancelItem.hovered ? colors.color4 : colors.color8
									strokeWidth: 1
									startX: 16 * root.scale; startY: 0
									PathLine { x: cancelItem.width; y: 0 }
									PathLine { x: cancelItem.width - (16 * root.scale); y: cancelItem.height }
									PathLine { x: 0; y: cancelItem.height }
									PathLine { x: 16 * root.scale; y: 0 }
								}
							}

							Text {
								anchors.centerIn: parent
								text: "ABORT_MISSION"
								color: cancelItem.hovered ? colors.color4 : colors.color8
								font.pixelSize: 12 * root.scale
								font.weight: 900
								font.family: "JetBrainsMono Nerd Font"
								font.letterSpacing: 1.2 * root.scale
							}
						}
						
						// Footer Technical Detail
						Text {
							text: "MAGI_02_REVISION // AUTHORITY_REQUIRED // UNIT_02"
							color: colors.muted
							font.pixelSize: 10 * root.scale
							font.weight: 800
							font.letterSpacing: 1.2 * root.scale
							font.wordSpacing: 1 * root.scale
							opacity: 0.6
							Layout.leftMargin: 20 * root.scale
						}
					}
				}
			}
		}
	}

	component PowerOption: Item {
		id: option
		property string label: ""
		property string subtext: ""
		property string action: ""

		width: 580 * root.scale
		height: 100 * root.scale
		
		property bool hovered: false
		
		readonly property color baseColor: hovered ? colors.color4 : colors.color1
		
		MouseArea {
			anchors.fill: parent
			hoverEnabled: true
			onEntered: option.hovered = true
			onExited: option.hovered = false
			onClicked: root.runAction(option.action)
		}

		Item {
			anchors.fill: parent
			clip: true

			Shape {
				anchors.fill: parent
				ShapePath {
					fillColor: colors.panelBg
					strokeColor: colors.color1
					strokeWidth: 2
					
					startX: 0; startY: 0
					PathLine { x: 580 * root.scale; y: 0 }
					PathLine { x: 540 * root.scale; y: 100 * root.scale }
					PathLine { x: 0; y: 100 * root.scale }
					PathLine { x: 0; y: 0 }
				}
			}

			Item {
				id: textBlock
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.top: parent.top
				anchors.bottom: parent.bottom
				anchors.margins: 20 * root.scale
				clip: true

				Column {
					anchors.verticalCenter: parent.verticalCenter
					spacing: -6 * root.scale

					Text {
						id: labelText
						text: option.label.toUpperCase()
						color: option.baseColor
						font.pixelSize: 34 * root.scale
						font.weight: 950
						font.letterSpacing: 1.6 * root.scale
						font.family: "JetBrainsMono Nerd Font"
						elide: Text.ElideRight
					}
					
					Text {
						text: option.subtext.toUpperCase()
						color: colors.muted
						font.pixelSize: 11 * root.scale
						font.weight: 800
						font.letterSpacing: 0.9 * root.scale
						font.wordSpacing: 0.8 * root.scale
						opacity: 0.65
						font.family: "JetBrainsMono Nerd Font"
						elide: Text.ElideRight
					}
				}
			}

			Item {
				anchors.right: parent.right
				anchors.rightMargin: 65 * root.scale
				anchors.verticalCenter: parent.verticalCenter
				width: 4 * root.scale
				height: 40 * root.scale
				
				Rectangle {
					anchors.fill: parent
					color: option.baseColor
					opacity: 0.5
				}
				
				Rectangle {
					anchors.centerIn: parent
					width: parent.width * 2
					height: parent.height + (10 * root.scale)
					color: option.baseColor
					visible: option.hovered
					opacity: 0.35
				}
			}
		}
	}
}
