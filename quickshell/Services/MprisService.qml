pragma Singleton
pragma ComponentBehavior: Bound

import QtQml.Models
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    property MprisPlayer trackedPlayer: null
    property MprisPlayer activePlayer: trackedPlayer ?? Mpris.players.values[0] ?? null

    property var activeTrack: ({
        uniqueId: 0,
        artUrl: "",
        title: "Unknown Title",
        artist: "Unknown Artist",
        album: "Unknown Album"
    })

    property real displayPosition: 0
    property real positionAnchor: 0
    property double positionAnchorTime: Date.now()
    property bool seeking: false
    property real seekTarget: 0

    property real length: activePlayer?.length ?? 0
    property real progress: length > 0
        ? Math.max(0, Math.min(1, displayPosition / length))
        : 0
    property bool shuffleSupported: activePlayer
        ? activePlayer.shuffleSupported && activePlayer.canControl
        : false
    property bool shuffleActive: activePlayer?.shuffle ?? false

    property bool loopSupported: activePlayer
        ? activePlayer.loopSupported && activePlayer.canControl
        : false
    property var loopState: activePlayer?.loopState ?? MprisLoopState.None
    property bool loopActive: loopState !== MprisLoopState.None
    property string loopIcon: loopState === MprisLoopState.Track
        ? "repeat_one"
        : "repeat"

    property bool canTogglePlaying: activePlayer?.canTogglePlaying ?? false
    property bool canGoPrevious: activePlayer?.canGoPrevious ?? false
    property bool canGoNext: activePlayer?.canGoNext ?? false
    property bool isPlaying: activePlayer?.isPlaying ?? false

    function setPositionAnchor(value) {
        const position = Math.max(0, Math.min(length, value))

        positionAnchor = position
        positionAnchorTime = Date.now()
        displayPosition = position
    }

    function syncPosition() {
        if (activePlayer)
            setPositionAnchor(activePlayer.position)
    }

    function seekTo(value) {
        const player = activePlayer

        if (!player?.canSeek)
            return

        const target = Math.max(0, Math.min(length, value))

        seeking = true
        seekTarget = target
        setPositionAnchor(target)

        player.position = target
    }

    function seekPercent(percent) {
        seekTo(length * Math.max(0, Math.min(1, percent)))
    }

    function toggleShuffle() {
        if (shuffleSupported)
            activePlayer.shuffle = !activePlayer.shuffle
    }

    function toggleLoop() {
        if (!loopSupported)
            return

        if (loopState === MprisLoopState.None)
            activePlayer.loopState = MprisLoopState.Track
        else if (loopState === MprisLoopState.Track)
            activePlayer.loopState = MprisLoopState.Playlist
        else
            activePlayer.loopState = MprisLoopState.None
    }

    function togglePlaying() {
        if (canTogglePlaying)
            activePlayer.togglePlaying()
    }

    function previous() {
        if (canGoPrevious)
            activePlayer.previous()
    }

    function next() {
        if (canGoNext)
            activePlayer.next()
    }

    function updateTrack() {
        const player = activePlayer

        activeTrack = {
            uniqueId: player?.uniqueId ?? 0,
            artUrl: player?.trackArtUrl ?? "",
            title: player?.trackTitle || "Unknown Title",
            artist: player?.trackArtist || "Unknown Artist",
            album: player?.trackAlbum || "Unknown Album"
        }
    }

    function fmt(seconds) {
        if (!Number.isFinite(seconds) || seconds <= 0)
            return "0:00"
        const value = Math.floor(seconds)
        return Math.floor(value / 60)
            + ":"
            + String(value % 60).padStart(2, "0")
    }

    Instantiator {
        model: Mpris.players

        Connections {
            required property MprisPlayer modelData
            target: modelData

            Component.onCompleted: {
                if (root.trackedPlayer === null || modelData.isPlaying)
                    root.trackedPlayer = modelData
            }

            Component.onDestruction: {
                if (root.trackedPlayer !== modelData)
                    return
                root.trackedPlayer = null
                for (const player of Mpris.players.values) {
                    if (player.isPlaying) {
                        root.trackedPlayer = player
                        return
                    }
                }

                root.trackedPlayer = Mpris.players.values[0] ?? null
            }

            function onPlaybackStateChanged() {
                if (modelData.isPlaying) {
                    root.trackedPlayer = modelData
                    return
                }

                if (modelData === root.activePlayer) {
                    root.seeking = false
                    root.setPositionAnchor(modelData.position)
                }
            }

            function onPositionChanged() {
                if (modelData !== root.activePlayer)
                    return
                if (root.seeking) {
                    if (Math.abs(modelData.position - root.seekTarget) < 1) {
                        root.seeking = false
                        root.setPositionAnchor(modelData.position)
                    }
                    return
                }

                root.setPositionAnchor(modelData.position)
            }

            function onLengthChanged() {
                if (modelData === root.activePlayer)
                    root.syncPosition()
            }
        }
    }

    Connections {
        target: root.activePlayer

        function onPostTrackChanged() {
            root.seeking = false
            root.updateTrack()
            root.syncPosition()
        }

        function onTrackArtUrlChanged() {
            root.updateTrack()
        }
    }

    onActivePlayerChanged: {
        root.seeking = false
        root.updateTrack()
        root.syncPosition()
    }

    Component.onCompleted: {
        Qt.callLater(() => {
            root.updateTrack()
            root.syncPosition()
        })
    }

    FrameAnimation {
        running: root.isPlaying && root.length > 0

        onTriggered: {
            root.displayPosition = Math.max(
                0,
                Math.min(
                    root.length,
                    root.positionAnchor
                        + (Date.now() - root.positionAnchorTime) / 1000
                )
            )
        }
    }
}