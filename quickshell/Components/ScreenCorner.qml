import qs.Appearance
import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland

Instantiator {
    id: cornerInstantiator

    readonly property var cornerPlacements: [
        {
            pos: "TopLeft",
            gap: false,
            topMargin: -7,
            shadow: true
        },
        {
            pos: "TopLeft",
            gap: true,
            topMargin: 0,
            shadow: false
        },
        {
            pos: "TopRight",
            gap: false,
            topMargin: -7,
            shadow: true
        },
        {
            pos: "TopRight",
            gap: true,
            topMargin: 0,
            shadow: false
        },
        {
            pos: "BottomLeft",
            gap: false,
            topMargin: 0,
            shadow: true
        },
        {
            pos: "BottomRight",
            gap: false,
            topMargin: 0,
            shadow: true
        }
    ]

    model: cornerPlacements

    delegate: PanelWindow {
        id: root

        required property var modelData

        readonly property string placement: modelData.pos
        readonly property bool fillsBarGap: modelData.gap
        readonly property int topMargin: modelData.topMargin
        readonly property bool shadowEnabled: modelData.shadow

        property color surfaceColor: Colors.bg

        readonly property int cornerSize: 26
        readonly property bool anchorsLeft: placement === "BottomLeft" || placement === "TopLeft"
        readonly property bool anchorsBottom: placement === "BottomLeft" || placement === "BottomRight"
        readonly property color fillColor: fillsBarGap ? Colors.shadow : surfaceColor

        anchors {
            bottom: anchorsBottom
            top: !anchorsBottom
            left: anchorsLeft
            right: !anchorsLeft
        }
        margins.top: root.topMargin
        color: "transparent"
        implicitWidth: cornerSize
        implicitHeight: cornerSize
        exclusionMode: fillsBarGap ? ExclusionMode.Ignore : ExclusionMode.Auto
        WlrLayershell.layer: WlrLayer.Top

        Shape {
            width: root.cornerSize
            height: root.cornerSize

            layer.enabled: true
            layer.samples: 4
            layer.effect: MultiEffect {
                shadowEnabled: root.shadowEnabled
                shadowColor: Colors.shadow
            }

            ShapePath {
                fillColor: root.fillColor
                strokeColor: "transparent"
                startX: root.anchorsLeft ? 0 : root.cornerSize
                startY: root.anchorsBottom ? root.cornerSize : 0

                PathLine {
                    x: root.anchorsLeft ? root.cornerSize : 0
                    y: root.anchorsBottom ? root.cornerSize : 0
                }

                PathQuad {
                    x: root.anchorsLeft ? 0 : root.cornerSize
                    y: root.anchorsBottom ? 0 : root.cornerSize
                    controlX: root.anchorsLeft ? 0 : root.cornerSize
                    controlY: root.anchorsBottom ? root.cornerSize : 0
                }

                PathLine {
                    x: root.anchorsLeft ? 0 : root.cornerSize
                    y: root.anchorsBottom ? root.cornerSize : 0
                }
            }
        }
    }
}