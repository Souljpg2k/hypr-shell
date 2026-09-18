import qs.Components
import Quickshell
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: bar
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: 45
    color: "transparent"

    readonly property int h: 30
    readonly property int bh: 38

    StyledShadow {
        width: parent.width - 10
        height: 30
    }

    Rectangle {
        width: parent.width
        height: bar.bh
        color: Colors.bg

        Row {
            anchors {
                left: parent.left
                leftMargin: 20
                verticalCenter: parent.verticalCenter
            }

            Item {
                width: 100
                height: bar.h

                RowLayout {
                    anchors.fill: parent
                    spacing: 7

                    AppSearch {
                        Layout.leftMargin: 3
                    }
                    ActiveWindow {}
                }
            }
        }

        Item {
            anchors {
                centerIn: parent
                horizontalCenterOffset: -60
            }
            width: 390
            height: bar.h

            RowLayout {
                anchors.centerIn: parent
                
                MediaPlayer {}
                UserName {}
                Workspaces {}
                DateTime {}
                HyprlandXkb {}
            }
        }

        Row {
            anchors {
                right: parent.right
                rightMargin: 15
                verticalCenter: parent.verticalCenter
            }

            Item {
                width: 170
                height: bar.h

                RowLayout {
                    spacing: -5

                    Item {
                        width: 110
                        height: 24

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: -8

                            Hyprshot {}
                            HyprPicker {}
                            DarkModeBtn {}
                        }
                    }
                    WifiButton {}
                    PowerButton {}
                }
            }
        }
    }
}