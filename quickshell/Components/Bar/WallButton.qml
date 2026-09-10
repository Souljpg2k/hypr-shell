import qs
import qs.Components
import QtQuick

StyledItem {
    MaterialIcon {
        anchors.centerIn: parent
        text: "wallpaper"
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: GlobalStates.toggleWallpaperPicker();
    }
}