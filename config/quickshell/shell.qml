import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
	id: root

	// --- Tactical Screen Detection ---
	readonly property var mainScreen: {
		const screens = Quickshell.screens.values;
		if (screens.length === 0) return null;
		for (let i = 0; i < screens.length; i++) {
			const s = screens[i];
			const w = s.geometry ? s.geometry.width : s.width;
			const h = s.geometry ? s.geometry.height : s.height;
			if (w > h) return s;
		}
		return screens[0];
	}

	Launcher {
		id: appLauncher
		screenInfo: root.mainScreen
	}
	
	// Pure Quickshell IPC
	IpcHandler {
		target: "launcher"
		function toggle(): void { appLauncher.toggle(); }
		function open(): void { appLauncher.open(); }
		function close(): void { appLauncher.close(); }
	}

	BottomPowerTag { screen: root.mainScreen }
	BatteryWidget { screen: root.mainScreen }
	MediaWidget { screen: root.mainScreen }
	BackgroundClock { screen: root.mainScreen }

	VolumeOsd { 
		modelData: root.mainScreen
		isMain: true
	}

	BrightnessOsd { 
		modelData: root.mainScreen
		isMain: true
	}
}
