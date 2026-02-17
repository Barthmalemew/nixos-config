pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    property bool sinkMuted: root.sink && root.sink.audio ? root.sink.audio.muted : false
    property real sinkVolume: root.sink && root.sink.audio ? root.sink.audio.volume : 0
    property string sinkIcon: {
        const volume = Math.round(sinkVolume * 100) / 100;
        if (sinkMuted) {
            return "fa_volume_xmark.svg";
        }
        if (volume >= 0.7) {
            return "fa_volume_high.svg";
        }
        if (volume >= 0.3) {
            return "fa_volume_low.svg";
        }
        return "fa_volume_off.svg";
    }

    function toggleSinkMute() {
        if (root.sink && root.sink.audio) {
            Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_SINK@", "toggle"]);
        }
    }

    function setSinkVolume(volume: real) {
        if (root.sink && root.sink.audio) {
            Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_SINK@", volume]);
        }
    }

    property bool sourceMuted: root.source && root.source.audio ? root.source.audio.muted : false
    property real sourceVolume: root.source && root.source.audio ? root.source.audio.volume : 0
    property string sourceIcon: {
        if (sourceMuted) {
            return "fa_microphone_lines_slash.svg";
        }
        return "fa_microphone_lines.svg";
    }

    function toggleSourceMute() {
        if (root.source && root.source.audio) {
            Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_SOURCE@", "toggle"]);
        }
    }

    function setSourceVolume(volume: real) {
        if (root.source && root.source.audio) {
            Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_SOURCE@", volume]);
        }
    }
}
