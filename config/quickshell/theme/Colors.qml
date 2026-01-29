import QtQuick

	QtObject {
		// Tuned to match `/home/barthmalemew/Pictures/Wallpapers/unit2.png`
		readonly property string background: "#34363a" // wallpaper base gray
		readonly property string foreground: "#efeae4"
		readonly property string cursor: foreground

	// UI surfaces (opaque; avoid translucent panels)
		readonly property string panelBg: "#26272a"
		readonly property string panelBg2: "#1f2022"
		readonly property string panelBorder: "#505257"
		readonly property string muted: "#b9b4ae"
		readonly property string outline: "#0b0b0c"

	// Large background clock + date (opaque, matches Unit-02 reds)
		readonly property string clockHour: "#c24f4f"
		readonly property string clockMinute: "#c24f4f"
		readonly property string clock: "#c24f4f"

		// Accent palette (subtle Unit-02 reds + muted orange)
		readonly property string color0: panelBg
		readonly property string color1: "#c24f4f" // red
		readonly property string color2: "#d17936" // muted orange
		readonly property string color3: "#b84a4a" // darker red alt
		readonly property string color4: "#a8ff00" // Unit-02 eye green
		readonly property string color5: "#cf5b5b" // highlight/borders
		readonly property string color6: "#d17936" // secondary accent
		readonly property string color7: foreground
		readonly property string color8: "#7a7c80" // dim text
		readonly property string color9: "#cf5b5b"
		readonly property string color10: "#d17936"
		readonly property string color11: "#d17936"
		readonly property string color12: "#c24f4f"
		readonly property string color13: "#d17936"
		readonly property string color14: foreground
		readonly property string color15: foreground

	readonly property string black: "#000000"
	readonly property string red: color1
	readonly property string green: color4
	readonly property string yellow: color5
	readonly property string blue: color4
	readonly property string magenta: color5
	readonly property string cyan: color6
	readonly property string white: foreground

	readonly property string brightBlack: color8
	readonly property string brightRed: color1
	readonly property string brightGreen: color4
	readonly property string brightYellow: color11
	readonly property string brightBlue: color12
	readonly property string brightMagenta: color5
	readonly property string brightCyan: color6
	readonly property string brightWhite: foreground
}
