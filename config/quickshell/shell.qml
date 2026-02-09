import QtQuick
import Quickshell
import Quickshell.Io

import "theme" as Theme

ShellRoot {
	id: root

	Theme.Colors { id: system }

	Instantiator {
		model: Quickshell.screens
		delegate: TopBar {
			screen: modelData
		}
	}
}
