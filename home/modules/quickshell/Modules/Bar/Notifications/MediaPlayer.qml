import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Modules.Bar.Notifications
import qs.Components
import qs.Config

RowLayout {
    id: root
    readonly property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
    width: parent.width
    visible: player !== null

    spacing: Size.iconTextPaddingLarge

    RoundedImage {
        id: cover
        Layout.preferredWidth: Size.mediaPlayerCoverSize
        Layout.preferredHeight: Size.mediaPlayerCoverSize
        fillMode: Image.PreserveAspectCrop
        source: root.player ? root.player.trackArtUrl : ""
        radius: Size.borderRadiusLarge
    }
    ColumnLayout {
        Layout.preferredHeight: Size.mediaPlayerCoverSize
        Layout.maximumHeight: Layout.preferredHeight
        Layout.preferredWidth: root.width - cover.Layout.preferredWidth - root.spacing
        Layout.maximumWidth: Layout.preferredWidth
        spacing: 0
        Text {
            text: root.player ? root.player.trackTitle : ""
            color: Colorscheme.text
            font.pointSize: Size.mediaPlayerTitle
            font.bold: true

            Layout.preferredWidth: parent.Layout.preferredWidth
            clip: true
            elide: Text.ElideRight
        }
        Text {
            text: root.player ? root.player.trackArtist : ""
            color: Colorscheme.text
            font.pointSize: Size.mediaPlayerArtist

            Layout.preferredWidth: parent.Layout.preferredWidth
            clip: true
            elide: Text.ElideRight
        }
        Item {
            Layout.fillHeight: true
        }
        RowLayout {
            PlayerButton {
                icon: "fa_backward_step.svg"
                onClicked: {
                    if (root.player) {
                        root.player.previous();
                    }
                }
            }
            PlayerButton {
                icon: root.player && root.player.isPlaying ? "fa_pause.svg" : "fa_play.svg"
                onClicked: {
                    if (root.player) {
                        root.player.togglePlaying();
                    }
                }
            }
            PlayerButton {
                icon: "fa_forward_step.svg"
                onClicked: {
                    if (root.player) {
                        root.player.next();
                    }
                }
            }
            Slider {
                id: slider
                enabled: false
                value: root.player && root.player.length > 0 ? root.player.position / root.player.length : 0
                Layout.fillWidth: true

                background: ClippingRectangle {
                    height: Size.mediaPlayerPositionHeight
                    color: Colorscheme.muted
                    radius: Size.borderRadiusLarge
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        width: slider.visualPosition * parent.width
                        height: parent.height
                        radius: Size.borderRadiusLarge
                        color: Colorscheme.text
                    }
                }

                handle: Item {}
            }
        }
    }
}
