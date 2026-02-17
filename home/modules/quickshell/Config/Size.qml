pragma Singleton

import Quickshell

Singleton {
    readonly property var screens: Quickshell.screens
    readonly property var primaryScreen: screens && screens.length > 0 ? screens[0] : null
    readonly property real referenceWidth: 1920
    readonly property real referenceHeight: 1080
    readonly property real outputScale: {
        if (!primaryScreen) {
            return 1;
        }
        return primaryScreen.scale || primaryScreen.devicePixelRatio || 1;
    }
    readonly property real screenWidthRaw: primaryScreen && primaryScreen.width ? primaryScreen.width : referenceWidth
    readonly property real screenHeightRaw: primaryScreen && primaryScreen.height ? primaryScreen.height : referenceHeight
    readonly property real logicalWidth: outputScale > 1.01 && screenWidthRaw > (referenceWidth * 1.15) ? screenWidthRaw / outputScale : screenWidthRaw
    readonly property real logicalHeight: outputScale > 1.01 && screenHeightRaw > (referenceHeight * 1.2) ? screenHeightRaw / outputScale : screenHeightRaw
    readonly property real uiScaleRaw: Math.min(logicalWidth / referenceWidth, logicalHeight / referenceHeight)
    readonly property real uiScale: Math.max(0.65, Math.min(1.0, uiScaleRaw))

    readonly property real borderWidth: 3
    readonly property real borderRadiusLarge: 16 * uiScale
    readonly property real borderRadiusSmall: 8 * uiScale

    readonly property real barWidth: Math.max(46, 48 * uiScale)
    readonly property real barWidgetInset: Math.max(4, 5 * uiScale)
    readonly property real barWidgetWidth: Math.max(28, barWidth - (barWidgetInset * 2))
    readonly property real barSectionSpacing: 8 * uiScale
    readonly property real barSectionMargin: 8 * uiScale

    readonly property real settingsPopupSpacing: Math.max(10, 16 * uiScale)
    readonly property real settingsPopupMargin: Math.max(10, 18 * uiScale)
    readonly property real settingsBoxWidthBase: 200 * uiScale
    readonly property real settingsBoxWidthFit: (logicalWidth - barWidth - (settingsPopupMargin * 2) - settingsPopupSpacing - 40) / 2
    readonly property real settingsBoxWidth: Math.max(150, Math.min(settingsBoxWidthBase, settingsBoxWidthFit))
    readonly property real settingsBoxHeightBase: 62 * uiScale
    readonly property real settingsBoxHeightFit: (logicalHeight - (settingsPopupMargin * 2) - (settingsPopupSpacing * 2) - (32 * uiScale)) / 3
    readonly property real settingsBoxHeight: Math.max(44, Math.min(settingsBoxHeightBase, settingsBoxHeightFit))
    readonly property real settingsBoxIconSize: Math.max(16, settingsBoxHeight * 0.34)
    readonly property real settingsBoxSpacing: Math.max(6, settingsBoxHeight * 0.15)
    readonly property real settingsBoxFontSize: Math.max(9, settingsBoxHeight * 0.18)
    readonly property real settingsStatusPadding: Math.max(3, 4 * uiScale)
    readonly property real settingsStatusSpacing: Math.max(5, 6 * uiScale)

    readonly property real notificationTitleFontSize: 14 * uiScale
    readonly property real notificationBodyFontSize: 12 * uiScale
    readonly property real notificationHeight: 140 * uiScale
    readonly property real notificationWidth: 440 * uiScale
    readonly property real notificationPadding: 20 * uiScale

    readonly property real iconTextPadding: 10 * uiScale
    readonly property real iconTextPaddingLarge: 20 * uiScale

    readonly property real launcherWidth: 600 * uiScale
    readonly property real launcherOuterPadding: 20 * uiScale
    readonly property real launcherInnerPadding: 10 * uiScale
    readonly property real launcherFontSize: 18 * uiScale

    readonly property real mediaPlayerTitle: 14 * uiScale
    readonly property real mediaPlayerArtist: 12 * uiScale
    readonly property real mediaPlayerPositionHeight: 10 * uiScale
    readonly property real mediaPlayerCoverSize: 100 * uiScale
}
