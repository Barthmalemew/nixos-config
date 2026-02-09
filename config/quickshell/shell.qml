import QtQuick
import Quickshell
import Quickshell.Io

import "theme" as Theme

ShellRoot {
	id: root

	Theme.Colors { id: system }

	// --- Tactical Screen Detection ---
	readonly property var mainScreen: {
		const screens = Quickshell.screens.values;
		if (screens.length === 0) return null;
		
		// Priority 1: Use the primary monitor defined in Nix
		for (let i = 0; i < screens.length; i++) {
			if (screens[i].name === system.primaryMonitor) return screens[i];
		}

		// Priority 2: First horizontal screen (Fallback)
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
	TopStatusBar { screen: root.mainScreen }
	
	// Stacking Order: Last = Top.
	// Background elements first, foreground widgets last.
	BackgroundClock { screen: root.mainScreen }
	BatteryWidget { 
		screen: root.mainScreen 
		enabled: system.isLaptop
	}
	MediaWidget { screen: root.mainScreen }

	VolumeOsd { 
		modelData: root.mainScreen
		isMain: true
		enabled: system.isLaptop
	}

	BrightnessOsd { 
		modelData: root.mainScreen
		isMain: true
		enabled: system.isLaptop
	}
}
