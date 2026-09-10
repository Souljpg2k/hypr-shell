import qs
import qs.Components
import QtQuick
import Quickshell

StyledItem {
    MaterialIcon {
        anchors.centerIn: parent
        text: "power_settings_new"
        font {
            bold: true
            pixelSize: 15
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                GlobalStates.toggleSysWidgets();
            else
                GlobalStates.togglePowerMenu();
        }
    }
}