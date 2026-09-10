pragma Singleton
pragma ComponentBehavior: Bound

import QtQml.Models
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    property MprisPlayer trackedPlayer: null
    property MprisPlayer activePlayer: {
        if (trackedPlayer)
            return trackedPlayer;
        return Mpris.players.values.length > 0 ? Mpris.players.values[0] : null;
    }

    property var activeTrack: ({
            uniqueId: 0,
            artUrl: "",
            title: "Unknown Title",
            artist: "Unknown Artist",
            album: "Unknown Album"
        })

    property real position: root.activePlayer?.position ?? 0
    property real length: root.activePlayer?.length ?? 0
    property real progress: {
        if (root.length <= 0)
            return 0;
        return Math.max(0, Math.min(1, root.position / root.length));
    }

    property bool loopSupported: root.activePlayer ? root.activePlayer.loopSupported && root.activePlayer.canControl : false
    property var loopState: root.activePlayer?.loopState ?? MprisLoopState.None
    property bool loopActive: root.loopState !== MprisLoopState.None
    property string loopIcon: {
        if (root.loopState === MprisLoopState.Track)
            return "repeat_one";
        return "repeat";
    }

    function toggleLoop() {
        const player = root.activePlayer;

        if (!player || !root.loopSupported)
            return;
        if (player.loopState === MprisLoopState.None)
            player.loopState = MprisLoopState.Track;
        else if (player.loopState === MprisLoopState.Track)
            player.loopState = MprisLoopState.Playlist;
        else
            player.loopState = MprisLoopState.None;
    }

    function seekTo(value) {
        const player = root.activePlayer;
        if (!player || !player.canSeek)
            return;
        player.position = Math.max(0, Math.min(root.length, value));
    }

    function seekPercent(percent) {
        root.seekTo(root.length * Math.max(0, Math.min(1, percent)));
    }

    function firstPlayer() {
        return Mpris.players.values.length > 0 ? Mpris.players.values[0] : null;
    }

    Instantiator {
        model: Mpris.players

        Connections {
            required property MprisPlayer modelData
            target: modelData
            Component.onCompleted: {
                if (root.trackedPlayer === null || modelData.isPlaying)
                    root.trackedPlayer = modelData;
            }
            Component.onDestruction: {
                if (root.trackedPlayer !== modelData)
                    return;
                root.trackedPlayer = null;
                for (const player of Mpris.players.values) {
                    if (player.isPlaying) {
                        root.trackedPlayer = player;
                        return;
                    }
                }
                root.trackedPlayer = root.firstPlayer();
            }

            function onPlaybackStateChanged() {
                if (modelData.isPlaying)
                    root.trackedPlayer = modelData;
            }
        }
    }

    Connections {
        target: root.activePlayer

        function onPostTrackChanged() {
            root.updateTrack();
        }
        
        function onTrackArtUrlChanged() {
            root.updateTrack();
        }
    }

    onActivePlayerChanged: root.updateTrack()

    function updateTrack() {
        const player = root.activePlayer;

        root.activeTrack = {
            uniqueId: player?.uniqueId ?? 0,
            artUrl: player?.trackArtUrl ?? "",
            title: player?.trackTitle || "Unknown Title",
            artist: player?.trackArtist || "Unknown Artist",
            album: player?.trackAlbum || "Unknown Album"
        };
    }

    property bool canTogglePlaying: root.activePlayer?.canTogglePlaying ?? false
    property bool canGoPrevious: root.activePlayer?.canGoPrevious ?? false
    property bool canGoNext: root.activePlayer?.canGoNext ?? false
    property bool isPlaying: root.activePlayer?.isPlaying ?? false

    function togglePlaying() {
        if (root.canTogglePlaying)
            root.activePlayer.togglePlaying();
    }

    function previous() {
        if (root.canGoPrevious)
            root.activePlayer.previous();
    }

    function next() {
        if (root.canGoNext)
            root.activePlayer.next();
    }

    function fmt(s) {
        if (!Number.isFinite(s) || s <= 0)
            return "0:00";
        const t = Math.floor(s);
        return Math.floor(t / 60) + ":" + String(t % 60).padStart(2, "0");
    }

    Timer {
        interval: 1000
        running: root.isPlaying && (root.activePlayer?.positionSupported ?? false)
        repeat: true
        onTriggered: {
            if (root.activePlayer)
                root.activePlayer.positionChanged();
        }
    }
}