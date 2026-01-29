import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Item {
	id: root

	property bool active: false

	property var previousCpuStats: null
	property double cpuUsage: 0

	property double memUsage: 0
	property string memText: "…"

	property double diskUsage: 0
	property string diskText: "…"

	Colors { id: colors }

	FileView {
		id: cpuFile
		path: "/proc/stat"
		onLoaded: {
			const cpuLine = text().match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/);
			if (!cpuLine) return;
			const stats = cpuLine.slice(1).map(Number);
			const total = stats.reduce((a, b) => a + b, 0);
			const idle = stats[3];

			if (previousCpuStats) {
				const totalDiff = total - previousCpuStats.total;
				const idleDiff = idle - previousCpuStats.idle;
				cpuUsage = totalDiff > 0 ? (1 - idleDiff / totalDiff) : 0;
			}

			previousCpuStats = { total, idle };
		}
	}

	FileView {
		id: memFile
		path: "/proc/meminfo"
		onLoaded: {
			const data = text();
			const totalMatch = data.match(/MemTotal:\s+(\d+)/);
			const availMatch = data.match(/MemAvailable:\s+(\d+)/);
			if (!totalMatch || !availMatch) return;

			const memoryTotal = parseInt(totalMatch[1]);
			const memoryAvailable = parseInt(availMatch[1]);
			const memoryUsed = memoryTotal - memoryAvailable;
			memUsage = memoryUsed / memoryTotal;

			const usedGB = (memoryUsed / 1024 / 1024).toFixed(1);
			const totalGB = (memoryTotal / 1024 / 1024).toFixed(1);
			memText = usedGB + " / " + totalGB + " GB";
		}
	}

	Process {
		id: diskProcess
		command: ["df", "-P", "/"]
		stdout: SplitParser {
			onRead: data => {
				let lines = data.trim().split("\\n");
				for (let line of lines) {
					let parts = line.trim().split(/\s+/);
					if (parts.length >= 6 && parts[5] === "/") {
						let total = Number(parts[1]);
						let used = Number(parts[2]);
						if (total > 0) {
							diskUsage = used / total;
							diskText =
								(used / 1024 / 1024).toFixed(1) +
								" / " +
								(total / 1024 / 1024).toFixed(1) +
								" GB";
						}
					}
				}
			}
		}
	}

	Timer {
		interval: 1000
		running: root.active
		repeat: true
		triggeredOnStart: true
		onTriggered: {
			cpuFile.reload();
			memFile.reload();
			if (!diskProcess.running) diskProcess.running = true;
		}
	}

	ColumnLayout {
		anchors.fill: parent
		spacing: 10

		StatRow {
			Layout.fillWidth: true
			label: "CPU"
			valueText: Math.round(root.cpuUsage * 100) + "%"
			value: root.cpuUsage
		}

		StatRow {
			Layout.fillWidth: true
			label: "RAM"
			valueText: root.memText
			value: root.memUsage
		}

		StatRow {
			Layout.fillWidth: true
			label: "Disk"
			valueText: root.diskText
			value: root.diskUsage
		}

		Item { Layout.fillHeight: true }
	}

	component StatRow: Item {
		id: row
		property string label: ""
		property string valueText: ""
		property real value: 0

		implicitHeight: 44

		ColumnLayout {
			anchors.fill: parent
			spacing: 4

			RowLayout {
				Layout.fillWidth: true
				spacing: 10

				Text {
					text: row.label
					color: colors.foreground
					font.pixelSize: 12
					font.weight: 600
				}

				Item { Layout.fillWidth: true }

				Text {
					text: row.valueText
					color: colors.brightBlack
					font.pixelSize: 11
					elide: Text.ElideRight
				}
			}

			Rectangle {
				Layout.fillWidth: true
				Layout.preferredHeight: 8
				radius: 999
				color: colors.panelBg2
				border.width: 1
				border.color: colors.panelBorder

				Rectangle {
					anchors.verticalCenter: parent.verticalCenter
					anchors.left: parent.left
					anchors.leftMargin: 1
					height: parent.height - 2
					width: Math.max(0, Math.round((parent.width - 2) * Math.min(1, Math.max(0, row.value))))
					radius: 999
					color: colors.color5
				}
			}
		}
	}
}
