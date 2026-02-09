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
  // This avoids hardcoding BAT0/AC and works across most laptops.
  Process {
    id: findHardware
    command: [
      "sh",
      "-c",
      "for d in /sys/class/power_supply/*; do t=$(cat \"$d/type\" 2>/dev/null); if [ \"$t\" = \"Battery\" ]; then echo \"BAT:$d\"; break; fi; done; " +
      "for d in /sys/class/power_supply/*; do t=$(cat \"$d/type\" 2>/dev/null); if [ \"$t\" = \"Mains\" ]; then " +
      "if [ -f \"$d/online\" ]; then echo \"ACFILE:$d/online\"; " +
      "elif [ -f \"$d/status\" ]; then echo \"ACFILE:$d/status\"; fi; break; fi; done"
    ]
    stdout: SplitParser {
      onRead: data => {
        const lines = (data || "").trim().split("\n");
        for (let i = 0; i < lines.length; i++) {
          const line = lines[i];
          if (line.startsWith("BAT:")) {
            root.batteryPath = line.slice(4);
          } else if (line.startsWith("ACFILE:")) {
            root.acPath = line.slice(7);
          }
        }
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
      const raw = text().trim();
      const value = parseInt(raw);
      if (!isNaN(value)) {
        root.acOnline = value;
        return;
      }
      // Fallback: some AC adapters expose "Charging"/"Discharging" in status
      const lower = raw.toLowerCase();
      if (lower.indexOf("charging") === 0 || lower.indexOf("full") === 0) {
        root.acOnline = 1;
      } else if (lower.indexOf("discharging") === 0) {
        root.acOnline = 0;
      } else {
        root.acOnline = -1;
      }
    }
  }
}
