import qs.Components
import qs.Services
import QtQuick

StyledItem {
    MaterialIcon {
        anchors.centerIn: parent
        text: NetworkingService.icon
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: NetworkingService.toggle()
    }
}