import qs.Appearance
import qs.Components
import qs.Services
import QtQuick
import Quickshell

Item {
    width: 50
    height: 18

    Row {
        spacing: 4
    
        MaterialIcon {
            text: "keyboard"
            font.pixelSize: Appearance.base + 3
        }

        StyledText {
            text: LayoutService.currentLayout
            font.pixelSize: Appearance.base + 1
            width: 20
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["hyprctl", "switchxkblayout", "all", "next"]);
    }
}
