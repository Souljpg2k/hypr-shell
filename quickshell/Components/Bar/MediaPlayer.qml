import qs
import qs.Appearance
import qs.Components
import qs.Components.Cava
import qs.Services
import QtQuick
import Quickshell
import Quickshell.Widgets

Item {
    width: 220
    height: 24

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: GlobalStates.toggleMediaControls()
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0)
                AudioService.volumeUp();
            else
                AudioService.volumeDown();
        }
    }

    Row {
        anchors.fill: parent
        leftPadding: 2

        ClippingRectangle {
            width: 22
            height: 22
            radius: Appearance.radius
            color: Colors.bg
            anchors.verticalCenter: parent.verticalCenter

            Image {
                anchors.fill: parent
                source: MprisService.activeTrack?.artUrl || "../../Assets/1.jpg"
                fillMode: Image.PreserveAspectCrop
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (GlobalStates.mediaControlsWlrLayer)
                        GlobalStates.mediaControlsWlrLayer = false;
                    else
                        GlobalStates.mediaControlsWlrLayer = true;
                }
            }
        }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            component TextInfo: StyledText {
                width: 80
                font.pixelSize: Appearance.base
                elide: Text.ElideRight
                leftPadding: 8
            }

            TextInfo {
                text: MprisService.activeTrack.artist
            }

            StyledText {
                text: "•"
            }

            TextInfo {
                text: MprisService.activeTrack.title
            }
        }
    }
}
