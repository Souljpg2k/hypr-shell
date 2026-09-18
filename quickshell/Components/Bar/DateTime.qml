import qs
import qs.Components
import qs.Services
import QtQuick

Item {
    width: 128
    height: 24

    Row {
        anchors.centerIn: parent
        spacing: 4

        StyledText {
            text: DateTimeService.date
        }

        StyledText {
            text: DateTimeService.time
        }
        
        StyledText {
            text: DateTimeService.ap
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: GlobalStates.toggleClock()
    }
}