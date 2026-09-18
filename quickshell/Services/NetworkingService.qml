pragma Singleton

import Quickshell
import Quickshell.Networking

Singleton {
    id: root

    readonly property var device: {
        for (const d of Networking.devices.values)
            if (d.type === DeviceType.Wifi)
                return d
        return null
    }

    readonly property bool enabled: Networking.wifiHardwareEnabled && Networking.wifiEnabled
    readonly property bool connected: device ? device.connected : false

    readonly property real strength: {
        if (!device)
            return 0
        for (const n of device.networks.values)
            if (n.connected)
                return n.signalStrength
        return 0
    }

    readonly property string icon: {
        if (!enabled)
            return "signal_wifi_off"
        if (!connected)
            return "signal_wifi_0_bar"
        if (strength >= 0.8) return "network_wifi"
        if (strength >= 0.6) return "network_wifi_3_bar"
        if (strength >= 0.4) return "network_wifi_2_bar"
        if (strength >= 0.2) return "network_wifi_1_bar"
        return "signal_wifi_0_bar"
    }

    function toggle() {
        Quickshell.execDetached(["kitty", "nmtui"])
    }
}