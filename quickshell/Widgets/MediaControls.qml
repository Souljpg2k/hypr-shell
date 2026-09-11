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

    anchors {
        top: true
        left: true
    }
    margins {
        left: 120
    }
    implicitWidth: 290
    implicitHeight: 140
    WlrLayershell.layer: GlobalStates.mediaControlsWlrLayer ? WlrLayer.Bottom : WlrLayer.Overlay
    color: "transparent"

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
                spacing: 5

                MaterialIcon {
                    text: AudioService.muteIcon
                    color: AudioService.muted ? Colors.error : Colors.pf
                    topPadding: -3
                }

                StyledText {
                    id: vol
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
                            if (GlobalStates.mediaControlsWlrLayer)
                                GlobalStates.mediaControlsWlrLayer = false
                            else
                                GlobalStates.mediaControlsWlrLayer = true
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
                    }

                    Rectangle {
                        id: seekBar
                        width: s.width
                        height: 6
                        radius: 3
                        color: Colors.sf

                        Rectangle {
                            width: seekBar.width * MprisService.progress
                            height: parent.height
                            radius: parent.radius
                            color: Colors.on_sf
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onPressed: mouse => {
                                MprisService.seekPercent(mouse.x / width)
                            }
                            onPositionChanged: mouse => {
                                if (pressed)
                                    MprisService.seekPercent(mouse.x / width)
                            }
                        }
                    }

                    StyledText {
                        width: p.width
                        text: MprisService.fmt(MprisService.position) + " / " + MprisService.fmt(MprisService.length)
                    }

                    Row {
                        id: c
                        spacing: 10
                        
                        property int fs: 24

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
                            font.pixelSize: c.fs
                            enabled: MprisService.loopSupported
                            color: MprisService.loopActive ? Colors.pf : Colors.on_bg
                            opacity: enabled ? 1 : 0.35

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
   
        Component.onCompleted: animation.startEnter()
    }

    function close() {
        if (closing)
            return
        closing = true
        animation.startExit()
    }

    Connections {
        target: GlobalStates

        function onMediaControlsCloseRequested() {
            root.close()
        }
    }
}