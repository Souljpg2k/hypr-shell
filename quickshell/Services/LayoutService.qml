pragma Singleton

import QtQml
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Singleton {
    id: root

    property string currentLayout: ""

    function setLayout(layout) {
        currentLayout = layout.substring(0, 2).toLowerCase()
    }

    Process {
        running: true
        command: ["hyprctl", "devices", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                const keyboard = JSON.parse(text).keyboards.find(k => k.main)
                if (keyboard) root.setLayout(keyboard.active_keymap)
            }
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activelayout")
                root.setLayout(event.data.split(",").pop().trim())
        }
    }
}