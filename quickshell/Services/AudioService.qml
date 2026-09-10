pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property int volumeText: sink?.audio ? Math.round(volume * 100) : 0
    readonly property string muteIcon: muted ? "graphic_eq_off" : "graphic_eq"

    PwObjectTracker {
        objects: [sink]
    }

    function setVolume(c) {
        Quickshell.execDetached([
            "wpctl", 
            "set-volume", 
            "-l", "1", "@DEFAULT_AUDIO_SINK@", 
            c
        ]);
    }

    function volumeUp() {
        setVolume("5%+");
    }

    function volumeDown() {
        setVolume("5%-");
    }
}
