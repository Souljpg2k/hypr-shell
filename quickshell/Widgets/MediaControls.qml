import qs
import qs.Appearance
import qs.Components
import qs.Services
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

PanelWindow {
    id: root

    property bool closing: false
    property real visualProgress: MprisService.progress
    property real wavePhase: 0
    property bool isSeeking: false

    anchors {
        top: true
        left: true
    }
    margins.left: 120
    implicitWidth: 290
    implicitHeight: 140
    WlrLayershell.layer: GlobalStates.mediaControlsWlrLayer ? WlrLayer.Bottom : WlrLayer.Overlay
    color: "transparent"

    function syncProgress() {
        if (!isSeeking)
            visualProgress = MprisService.progress;
    }

    Timer {
        interval: 16
        running: MprisService.isPlaying && MprisService.length > 0 && !root.isSeeking
        repeat: true

        onTriggered: {
            root.wavePhase += 0.12;

            if (root.wavePhase > Math.PI * 2)
                root.wavePhase -= Math.PI * 2;
        }
    }

    Connections {
        target: MprisService

        function onPositionChanged() {
            root.syncProgress();
        }

        function onLengthChanged() {
            root.syncProgress();
        }

        function onProgressChanged() {
            root.syncProgress();
        }

        function onActivePlayerChanged() {
            root.syncProgress();
        }
    }

    Item {
        id: content

        width: parent.width
        height: parent.height
        opacity: 0
        scale: 0.94
        transformOrigin: Item.Top

        StyledShadow {
            anchors.centerIn: b
            width: b.width
            height: b.height
        }

        Rectangle {
            id: b

            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                topMargin: 10
            }

            width: 280
            height: 120
            color: Colors.bg
            radius: Appearance.base + 6

            Row {
                anchors {
                    right: parent.right
                    rightMargin: 10
                    top: parent.top
                    topMargin: 8
                }
                spacing: 3

                MaterialIcon {
                    text: AudioService.muteIcon
                    font.pixelSize: 16
                    color: AudioService.muted ? Colors.error : Colors.pf
                    topPadding: -3
                }

                StyledText {
                    text: AudioService.volumeText
                    color: Colors.pf
                    opacity: 0.7
                    width: 20
                }
            }

            Row {
                anchors {
                    left: parent.left
                    leftMargin: 10
                    top: parent.top
                    topMargin: 10
                }

                spacing: 10

                ClippingRectangle {
                    width: 100
                    height: 100
                    radius: 8
                    color: Colors.sf

                    Image {
                        anchors.fill: parent
                        source: MprisService.activeTrack.artUrl || "../Assets/1.jpg"
                        fillMode: Image.PreserveAspectCrop
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            GlobalStates.mediaControlsWlrLayer = !GlobalStates.mediaControlsWlrLayer;
                        }
                    }
                }

                Column {
                    topPadding: 2
                    spacing: 4

                    StyledText {
                        id: p
                        width: 100
                        text: MprisService.activeTrack.artist
                        elide: Text.ElideRight
                    }

                    StyledText {
                        id: s
                        width: 145
                        text: MprisService.activeTrack.title
                        elide: Text.ElideRight
                        topPadding: -5
                    }

                    Row {
                        StyledText {
                            id: t
                            text: MprisService.fmt(MprisService.displayPosition)
                            width: 30
                        }
                        StyledText {
                            text: " / "
                            width: t.width -15
                        }
                        StyledText {
                            text: MprisService.fmt(MprisService.length)
                            width: t.width
                        }
                    }

                    Item {
                        id: seekBar
                        width: s.width
                        height: 14

                        property real progressWidth: width * root.visualProgress

                        Rectangle {
                            id: remainingTrack
                            x: seekBar.progressWidth
                            y: (seekBar.height - height) / 2
                            width: Math.max(0, seekBar.width - x)
                            height: 4
                            radius: 2
                            color: Colors.sf
                        }

                        Item {
                            width: seekBar.progressWidth + 4
                            height: seekBar.height
                            clip: true

                            Canvas {
                                id: waveCanvas

                                property real strokeWidth: 4

                                width: seekBar.width + strokeWidth / 2
                                height: seekBar.height

                                onPaint: {
                                    const ctx = getContext("2d");

                                    ctx.clearRect(0, 0, width, height);

                                    const centerY = height / 2;
                                    const amplitude = 2;
                                    const wavelength = 20;
                                    const segmentLength = wavelength / 2;
                                    const controlOffset = amplitude * 2;
                                    const r = strokeWidth / 2;
                                    const fadeInLength = strokeWidth;

                                    const scrollX = root.wavePhase / (Math.PI * 2) * wavelength;

                                    ctx.beginPath();

                                    for (let x = 0; x <= seekBar.width; x++) {
                                        const shifted = x + scrollX;
                                        const segment = Math.floor(shifted / segmentLength);
                                        const t = (shifted - segment * segmentLength) / segmentLength;
                                        const direction = segment % 2 === 0 ? 1 : -1;
                                        const d = 2 * t * (1 - t) * controlOffset * direction;
                                        const envelope = Math.min(x / fadeInLength, 1);
                                        const y = centerY + d * envelope;

                                        if (x === 0)
                                            ctx.moveTo(x + r, y);
                                        else
                                            ctx.lineTo(x + r, y);
                                    }

                                    ctx.strokeStyle = Colors.on_sf;
                                    ctx.lineWidth = strokeWidth;
                                    ctx.lineCap = "round";
                                    ctx.lineJoin = "round";
                                    ctx.stroke();
                                }

                                Connections {
                                    target: root

                                    function onWavePhaseChanged() {
                                        waveCanvas.requestPaint();
                                    }
                                }

                                Component.onCompleted: requestPaint()
                            }
                        }

                        Rectangle {
                            id: seekHandle
                            width: 12
                            height: 12
                            radius: width / 2
                            color: Colors.on_sf
                            x: seekBar.progressWidth - width / 2
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        MouseArea {
                            anchors.fill: parent
                            z: 10
                            cursorShape: Qt.PointingHandCursor

                            onPressed: mouse => {
                                root.isSeeking = true;
                                root.visualProgress = Math.max(0, Math.min(1, mouse.x / width));
                            }

                            onPositionChanged: mouse => {
                                if (!pressed)
                                    return;
                                root.visualProgress = Math.max(0, Math.min(1, mouse.x / width));
                            }

                            onReleased: {
                                const pct = root.visualProgress;

                                MprisService.seekPercent(pct);
                                root.isSeeking = false;
                                root.visualProgress = pct;
                            }

                            onCanceled: {
                                root.isSeeking = false;
                                root.syncProgress();
                            }
                        }
                    }

                    Row {
                        id: c
                        spacing: 8

                        property int fs: 22

                        MaterialIcon {
                            text: "shuffle"
                            font.pixelSize: c.fs -5
                            enabled: MprisService.shuffleSupported
                            color: MprisService.shuffleActive ? Colors.pf : Colors.on_bg
                            opacity: enabled ? 1 : 0.35
                            topPadding: 3

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: MprisService.toggleShuffle()
                            }
                        }

                        MaterialIcon {
                            text: "skip_previous"
                            font.pixelSize: c.fs
                            enabled: MprisService.canGoPrevious
                            opacity: enabled ? 1 : 0.35

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: MprisService.previous()
                            }
                        }

                        MaterialIcon {
                            text: MprisService.isPlaying ? "pause" : "play_arrow"
                            font.pixelSize: c.fs
                            enabled: MprisService.canTogglePlaying
                            opacity: enabled ? 1 : 0.35

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: MprisService.togglePlaying()
                            }
                        }

                        MaterialIcon {
                            text: "skip_next"
                            font.pixelSize: c.fs
                            enabled: MprisService.canGoNext
                            opacity: enabled ? 1 : 0.35

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: MprisService.next()
                            }
                        }

                        MaterialIcon {
                            text: MprisService.loopIcon
                            font.pixelSize: c.fs -6
                            enabled: MprisService.loopSupported
                            color: MprisService.loopActive ? Colors.pf : Colors.on_bg
                            opacity: enabled ? 1 : 0.35
                            topPadding: 4

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: MprisService.toggleLoop()
                            }
                        }
                    }
                }
            }
        }

        Animations {
            id: animation
            target: content
            enterX: 0
            enterY: -10
            exitX: 0
            exitY: -24
            onExited: GlobalStates.mediaControlsVisible = false
        }

        Component.onCompleted: {
            root.syncProgress();
            animation.startEnter();
        }
    }

    function close() {
        if (closing)
            return;
        closing = true;
        animation.startExit();
    }

    Connections {
        target: GlobalStates

        function onMediaControlsCloseRequested() {
            root.close();
        }
    }
}
