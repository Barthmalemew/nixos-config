import QtQuick
import Quickshell
import Quickshell.Io

import "theme" as Theme

ShellRoot {
	id: root

	Theme.Colors { id: system }

	// --- Tactical Display Grid ---
	// We map components over all connected screens. Each component internally 
	// decides if it should render based on its 'screen' property.
	
	Instantiator {
		model: Quickshell.screens
		delegate: Scope {
			id: screenScope
			readonly property var screen: modelData
			readonly property bool isPrimary: screenScope.screen.name === system.primaryMonitor

			// Tactical Utility Components (Primary Only)
			Launcher {
				id: appLauncher
				enabled: screenScope.isPrimary
				screenInfo: screenScope.screen
				
				IpcHandler {
					enabled: screenScope.isPrimary
					target: "launcher"
					function toggle(): void { appLauncher.toggle(); }
					function open(): void { appLauncher.open(); }
					function close(): void { appLauncher.close(); }
				}
			}

			// Workspace-Aware Top Bar (Primary Only)
			TopStatusBar { 
				enabled: screenScope.isPrimary
				screen: screenScope.screen 
			}

			// Theming & Branding (Primary Only)
			BackgroundClock { 
				enabled: screenScope.isPrimary
				screen: screenScope.screen 
			}
			
			BottomPowerTag { 
				enabled: screenScope.isPrimary
				screen: screenScope.screen 
			}
			
			// Hardware Status (Primary Only)
			BatteryWidget { 
				screen: screenScope.screen 
				enabled: system.isLaptop && screenScope.isPrimary
			}
			
			MediaWidget { 
				enabled: screenScope.isPrimary
				screen: screenScope.screen 
			}

			// On-Screen Displays (Show on ALL screens for feedback)
			VolumeOsd { 
				modelData: screenScope.screen
				isMain: true
				enabled: system.isLaptop
			}

			BrightnessOsd { 
				modelData: screenScope.screen
				isMain: true
				enabled: system.isLaptop
			}
		}
	}
}
