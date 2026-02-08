import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris

import "theme" as Theme

PanelWindow {
	id: win

	visible: true

	Theme.Colors { id: colors }

	readonly property real scale: colors.scale

	// --- POSITIONING ---
	readonly property int anchorX: 45 * win.scale
	readonly property int anchorY: 210 * win.scale

	anchors {
		left: true
		bottom: true
	}

	margins {
		left: win.anchorX
		bottom: win.anchorY
	}

	color: "transparent"
	
	implicitWidth: 440 * win.scale
	implicitHeight: 175 * win.scale

	// Move to Bottom layer to stay with wallpaper
	WlrLayershell.layer: WlrLayer.Bottom
	WlrLayershell.exclusionMode: ExclusionMode.Ignore
	WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
	WlrLayershell.namespace: "qs-media-sdat-tactical"
	
	// Only capture mouse events on the actual walkman
	mask: Region { item: chassis }

	// --- INTERNAL COMPONENTS ---
	component ControlBtn: Rectangle {
		id: btn
		property string icon: ""
		property bool isMain: false
		property bool enabled: true
		property var act: function() {}
		
		width: isMain ? (70 * win.scale) : (50 * win.scale); height: 40 * win.scale
		color: (mouse.pressed && enabled) ? colors.color4 : (mouse.containsMouse ? colors.deepSurface : colors.panelBg2)
		border.color: (mouse.containsMouse && enabled) ? colors.color4 : colors.panelBorder
		border.width: mouse.containsMouse ? 2 : 1
		radius: 2
		opacity: enabled ? 1.0 : 0.3
		
		scale: (mouse.pressed && enabled) ? 0.9 : 1.0
		Behavior on scale { NumberAnimation { duration: 50 } }
		
		Text { 
			anchors.centerIn: parent; 
			text: btn.icon; 
			color: (mouse.pressed && enabled) ? colors.black : ((mouse.containsMouse && enabled) ? colors.color4 : colors.color2); 
			font.pixelSize: isMain ? (22 * win.scale) : (18 * win.scale) 
			font.weight: 900
		}
		
		MouseArea { 
			id: mouse; 
			anchors.fill: parent; 
			hoverEnabled: btn.enabled; 
			cursorShape: btn.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
			onClicked: {
				if (btn.enabled) btn.act();
			}
		}
		
		Behavior on color { ColorAnimation { duration: 100 } }
		Behavior on opacity { NumberAnimation { duration: 200 } }
	}

	// --- DATA LOGIC ---
	readonly property var player: {
		Mpris.players.count; 
		const players = Mpris.players.values;
		if (players.length === 0) return null;
		
		// Priority 1: Actually Playing (State 1) AND position < length
		for (let i = 0; i < players.length; i++) {
			const p = players[i];
			if (p.playbackState === 1 && (p.position < p.length - 0.5 || p.length <= 0)) return p;
		}

		// Priority 2: Actually Playing (State 1) - even if position looks stuck
		for (let i = 0; i < players.length; i++) {
			if (players[i].playbackState === 1) return players[i];
		}
		
		// Priority 3: Paused Vivaldi (State 2) with valid track
		for (let i = 0; i < players.length; i++) {
			const p = players[i];
			if (p.identity.toLowerCase().indexOf("vivaldi") !== -1 && p.playbackState === 2) {
				// Only return if it's not at the very end
				if (p.position < p.length - 0.5 || p.length <= 0) return p;
			}
		}
		
		return players[0];
	}

	readonly property bool isPlaying: !!win.player && win.player.playbackState === 1
	readonly property color accentColor: isPlaying ? colors.color4 : colors.color2

	property real smoothPosition: 0
	property int _driftCount: 0
	
	onPlayerChanged: {
		if (player) {
			smoothPosition = (player.position >= player.length && player.length > 0) ? 0 : player.position;
		}
	}

	onTrackTitleChanged: {
		smoothPosition = 0;
		_driftCount = 0;
	}

	Connections {
		target: win.player
		ignoreUnknownSignals: true
		function onPositionChanged() {
			if (win.player && (win.player.position < win.trackLength - 0.5 || win.trackLength <= 0)) {
				win.smoothPosition = win.player.position;
			}
		}
		function onPlaybackStateChanged() {
			if (win.player) win.smoothPosition = win.player.position;
		}
	}

	Timer {
		id: smoothTimer
		interval: 100
		running: win.isPlaying
		repeat: true
		onTriggered: {
			win.smoothPosition += 0.1;
			if (win.trackLength > 0 && win.smoothPosition > win.trackLength) {
				win.smoothPosition = win.trackLength;
			}
			
			if (win._driftCount++ >= 20) {
				// Only resync if the player isn't stuck at the end
				if (win.player && (win.player.position < win.trackLength - 0.5 || win.trackLength <= 0)) {
					win.smoothPosition = win.player.position;
				}
				win._driftCount = 0;
			}
		}
	}

	function resolveArtUrl() {
		if (!win.player) return "";
		return win.player.trackArtUrl || (win.player.metadata ? win.player.metadata["mpris:artUrl"] : "") || "";
	}

	readonly property string trackTitle: !!win.player ? (win.player.trackTitle || "---") : "OFFLINE"
	readonly property string trackArtist: !!win.player ? (win.player.trackArtist || "---") : "SIGNAL_LOSS"
	readonly property real trackLength: !!win.player ? (win.player.length || 0) : 0
	readonly property real progressRatio: (win.trackLength > 0) ? Math.min(1.0, win.smoothPosition / win.trackLength) : 0

	// --- UI ASSEMBLY ---
	Item {
		id: chassis
		width: 440 * win.scale
		height: 175 * win.scale

		MouseArea {
			anchors.fill: parent
			propagateComposedEvents: true
			onPressed: (mouse) => mouse.accepted = false
		}

		Rectangle {
			anchors.fill: parent
			color: colors.panelBg
			border.color: colors.panelBorder
			border.width: 2
			radius: 2

			// INDUSTRIAL TOP RAIL
			Rectangle {
				width: parent.width; height: 26 * win.scale
				color: colors.panelBg2
				anchors.top: parent.top
				
				RowLayout {
					anchors.fill: parent
					anchors.leftMargin: 14 * win.scale; anchors.rightMargin: 14 * win.scale
					Text {
						text: "SDAT-02 // DIGITAL_RECORDER"
						color: colors.color1
						font.pixelSize: 10 * win.scale
						font.weight: 950
						font.letterSpacing: 1 * win.scale
					}
					Item { Layout.fillWidth: true }
					
					// STATUS LIGHT (RED/ORANGE)
					Rectangle { 
						width: 8 * win.scale; height: 8 * win.scale; radius: 4 * win.scale; 
						color: !win.player ? colors.panelBorder : (win.isPlaying ? colors.color1 : colors.color2)
						
						Behavior on color { ColorAnimation { duration: 200 } }

						Timer {
							interval: 500
							running: win.isPlaying
							repeat: true
							onTriggered: parent.opacity = (parent.opacity === 1.0 ? 0.4 : 1.0)
							onRunningChanged: if (!running) parent.opacity = 1.0
						}
					}
					Text {
						text: !win.player ? "DISC" : (win.isPlaying ? "REC" : "STBY")
						color: !win.player ? colors.muted : (win.isPlaying ? colors.color1 : colors.color2)
						font.pixelSize: 8 * win.scale
						font.weight: 950
					}
				}
			}

			// MAIN INTERFACE AREA
			ColumnLayout {
				anchors.top: parent.top
				anchors.topMargin: 38 * win.scale
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.margins: 14 * win.scale
				spacing: 14 * win.scale

				RowLayout {
					Layout.fillWidth: true
					spacing: 14 * win.scale

					Item {
						Layout.preferredWidth: 130 * win.scale; Layout.preferredHeight: 75 * win.scale
						Rectangle {
							anchors.fill: parent
							color: colors.darkSurface
							border.color: colors.panelBorder
							clip: true
							Image {
								anchors.fill: parent
								source: resolveArtUrl()
								fillMode: Image.PreserveAspectCrop
								opacity: 0.25
								visible: status === Image.Ready
							}
							Row {
								anchors.centerIn: parent
								spacing: 25 * win.scale
								Repeater {
									model: 2
									Rectangle {
										width: 36 * win.scale; height: 36 * win.scale; radius: 18 * win.scale
										color: "transparent"; border.color: win.accentColor; border.width: 1; opacity: 0.4
										Rectangle { width: 3 * win.scale; height: 6 * win.scale; color: win.accentColor; anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter }
										RotationAnimation on rotation { from: 0; to: 360; duration: 2500; running: win.isPlaying; loops: Animation.Infinite }
									}
								}
							}
						}
					}

					Rectangle {
						Layout.fillWidth: true; Layout.preferredHeight: 75 * win.scale
						color: colors.midSurface
						border.color: colors.panelBorder
						ColumnLayout {
							anchors.fill: parent; anchors.margins: 10 * win.scale; spacing: 0
							RowLayout {
								Layout.fillWidth: true
								Text { 
									text: win.isPlaying ? "PLAY" : "STOP"
									color: win.isPlaying ? colors.color4 : colors.color2
									font.pixelSize: 18 * win.scale
									font.weight: 950 
								}
								Item { Layout.fillWidth: true }
								// LP LIGHT (GREEN WHEN ACTIVE)
								Text { 
									text: "LP"; 
									color: colors.color4; 
									font.pixelSize: 10 * win.scale; 
									font.weight: 950; 
									opacity: win.player ? 1 : 0.2 
									
									Behavior on opacity { NumberAnimation { duration: 300 } }
								}
							}
							Text {
								Layout.fillWidth: true
								text: win.trackTitle.toUpperCase()
								color: colors.foreground
								font.pixelSize: 13 * win.scale; font.weight: 950
								elide: Text.ElideRight
							}
							Text {
								Layout.fillWidth: true
								text: win.trackArtist.toUpperCase()
								color: colors.muted
								font.pixelSize: 9 * win.scale; font.weight: 800
								elide: Text.ElideRight
							}
						}
					}
				}

				// BOTTOM ROW: THE BUTTONS
				RowLayout {
					Layout.fillWidth: true
					spacing: 12 * win.scale

					Row {
						spacing: 8 * win.scale
						ControlBtn { 
							icon: "󰼨"
							enabled: win.player ? win.player.canGoPrevious : false
							act: function() { win.player.previous(); } 
						}
						ControlBtn { 
							icon: win.isPlaying ? "󰏤" : ""
							enabled: !!win.player
							act: function() { 
								if (!win.player) return;
								
								if (win.player.playbackState === 1) {
									win.player.pause();
								} else {
									win.player.play();
								}
								// Force immediate re-evaluation
								win.smoothPosition = win.player.position;
							}
							isMain: true 
						}
						ControlBtn { 
							icon: "󰼧"
							enabled: win.player ? win.player.canGoNext : false
							act: function() { win.player.next(); }
						}
					}

					// INTERACTIVE PROGRESS BAR
					Rectangle {
						id: progTrack
						Layout.fillWidth: true; Layout.preferredHeight: 6 * win.scale
						color: colors.deepSurface
						
						Rectangle {
							height: parent.height; width: Math.min(progTrack.width, progTrack.width * win.progressRatio)
							color: win.isPlaying ? colors.color4 : colors.color2
						}
						
						MouseArea {
							anchors.fill: parent
							onClicked: (mouse) => {
								if (win.player && win.trackLength > 0) {
									let pos = (mouse.x / width) * win.trackLength;
									win.player.position = pos;
									win.smoothPosition = pos;
								}
							}
						}
					}
				}
			}

			Rectangle {
				width: 6 * win.scale; height: 6 * win.scale; radius: 3 * win.scale; color: colors.panelBorder
				anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 8 * win.scale; opacity: 0.4
			}
		}
	}
}
