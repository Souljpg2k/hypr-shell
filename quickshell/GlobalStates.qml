pragma Singleton

import Quickshell

Singleton {
    id: root

    property bool screenLocked: false
    property bool powerMenuVisible: false
    property bool powerMenuClosing: false
    property bool wallpaperPickerVisible: false
    property bool userWidgetsVisible: false

    signal wallpaperCloseRequested
    signal userWidgetsCloseRequested
    signal sysWidgetsCloseRequested
    signal mediaControlsCloseRequested

    PersistentProperties {
        id: persist
        reloadableId: "globalStatesPersist"

        property bool sysWidgetsVisible: false
        property bool clockVisible: false
        property bool clockClosing: false
        property bool clockHiddenByPowerMenu: false
        property bool clockHiddenByWallpaperPicker: false
        property bool mediaControlsVisible: false
        property bool mediaControlsWlrLayer: false
    }

    property alias sysWidgetsVisible: persist.sysWidgetsVisible
    property alias clockVisible: persist.clockVisible
    property alias clockClosing: persist.clockClosing
    property alias clockHiddenByPowerMenu: persist.clockHiddenByPowerMenu
    property alias clockHiddenByWallpaperPicker: persist.clockHiddenByWallpaperPicker
    property alias mediaControlsVisible: persist.mediaControlsVisible
    property alias mediaControlsWlrLayer: persist.mediaControlsWlrLayer

    function showClock() {
        clockVisible = true;
        clockClosing = false;
    }

    function hideClock() {
        if (!clockVisible)
            return;
        clockClosing = true;
        clockVisible = false;
    }

    function toggleClock() {
        if (clockVisible)
            hideClock();
        else
            showClock();
    }

    function toggleSysWidgets() {
        if (sysWidgetsVisible)
            sysWidgetsCloseRequested();
        else
            sysWidgetsVisible = true;
    }

    function togglePowerMenu() {
        if (powerMenuVisible)
            closePowerMenu();
        else
            openPowerMenu();
    }

    function openPowerMenu() {
        powerMenuVisible = true;
        powerMenuClosing = false;

        if (clockVisible) {
            clockHiddenByPowerMenu = true;
            hideClock();
        }
    }

    function closePowerMenu() {
        powerMenuClosing = true;

        if (clockHiddenByPowerMenu) {
            clockHiddenByPowerMenu = false;
            showClock();
        }
    }

    onWallpaperPickerVisibleChanged: {
        if (wallpaperPickerVisible) {
            if (clockVisible) {
                clockHiddenByWallpaperPicker = true;
                hideClock();
            }
        } else if (clockHiddenByWallpaperPicker) {
            clockHiddenByWallpaperPicker = false;
            showClock();
        }
    }

    function toggleWallpaperPicker() {
        if (wallpaperPickerVisible)
            wallpaperCloseRequested();
        else
            wallpaperPickerVisible = true;
    }

    function toggleUserWidgets() {
        if (userWidgetsVisible)
            userWidgetsCloseRequested();
        else
            userWidgetsVisible = true;
    }

    function toggleMediaControls() {
        if (mediaControlsVisible)
            mediaControlsCloseRequested();
        else
            mediaControlsVisible = true;
    }
}
