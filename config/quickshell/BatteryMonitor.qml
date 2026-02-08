import QtQuick
import Quickshell
import Quickshell.Io

Scope {
  id: root
  
  property int capacity: 0
  property string status: ""
  property int acOnline: -1
  
  property bool present: batteryPath.length > 0
  property string batteryPath: ""
  property string acPath: ""

  // Scrape /sys/class/power_supply for battery and AC state
  Process {
    id: findHardware
    command: ["sh", "-c", "ls -1 /sys/class/power_supply | grep '^BAT' | head -n1; ls -1 /sys/class/power_supply | grep -E 'AC|ADP' | head -n1"]
    stdout: SplitParser {
      onRead: data => {
        const lines = (data || "").trim().split("\n");
        if (lines[0]) root.batteryPath = "/sys/class/power_supply/" + lines[0];
        if (lines[1]) root.acPath = "/sys/class/power_supply/" + lines[1] + "/online";
      }
    }
  }

  Component.onCompleted: findHardware.running = true

  Timer {
    interval: 2000
    running: root.batteryPath.length > 0 || root.acPath.length > 0
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      if (root.batteryPath) {
        capacityFile.reload();
        statusFile.reload();
      }
      if (root.acPath) acFile.reload();
    }
  }
  
  FileView {
    id: capacityFile
    path: root.batteryPath ? (root.batteryPath + "/capacity") : ""
    onLoaded: root.capacity = parseInt(text().trim())
  }
  
  FileView {
    id: statusFile
    path: root.batteryPath ? (root.batteryPath + "/status") : ""
    onLoaded: root.status = text().trim()
  }

  FileView {
    id: acFile
    path: root.acPath
    onLoaded: {
      const value = parseInt(text().trim());
      root.acOnline = isNaN(value) ? -1 : value;
    }
  }
}
