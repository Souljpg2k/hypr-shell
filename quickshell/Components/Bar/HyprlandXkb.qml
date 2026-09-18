import qs.Appearance
import qs.Components
import qs.Services
import QtQuick
import Quickshell

StyledItem {
    Row {
        anchors.centerIn: parent
        spacing: 4
    
        MaterialIcon {
            text: "keyboard"
            topPadding: -1
        }

        StyledText {
            text: LayoutService.currentLayout
            font.pixelSize: Appearance.base
            width: 20
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["hyprctl", "switchxkblayout", "all", "next"])
    }
}