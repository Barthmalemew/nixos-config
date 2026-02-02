import QtQuick
import Quickshell
import Quickshell.Io

Scope {
  id: root
  
  property int capacity: 0
  property string status: ""
  property int acOnline: -1
  property int energyNow: 0
  property int energyFull: 0
  property int powerNow: 0
  property int timeToEmpty: 0
  property int timeToFull: 0
  
  property int pollIntervalMs: 2000
  property bool present: batteryPath.length > 0
  property string batteryPath: ""

  property alias updateTimer: _updateTimer

  property string acPath: ""

  Process {
    id: findBattery
    command: ["sh", "-c", "ls -1 /sys/class/power_supply | grep '^BAT' | head -n1"]
    stdout: SplitParser {
      onRead: data => {
        const name = (data || "").trim();
        if (name) root.batteryPath = "/sys/class/power_supply/" + name;
      }
    }
  }

  Process {
    id: findAC
    command: ["sh", "-c", "ls -1 /sys/class/power_supply | grep -E 'AC|ADP' | head -n1"]
    stdout: SplitParser {
      onRead: data => {
        const name = (data || "").trim();
        if (name) root.acPath = "/sys/class/power_supply/" + name + "/online";
      }
    }
  }

  Component.onCompleted: {
    findBattery.running = true;
    findAC.running = true;
  }

  Timer {
    id: _updateTimer
    interval: root.pollIntervalMs
    running: root.batteryPath.length > 0 || root.acPath.length > 0
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      if (root.batteryPath) {
        capacityFile.reload()
        statusFile.reload()
        energyNowFile.reload()
        energyFullFile.reload()
        powerNowFile.reload()
      }
      if (root.acPath) {
        acFile.reload()
      }
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
    onLoaded: {
      root.status = text().trim()
    }
  }

  FileView {
    id: acFile
    path: root.acPath
    onLoaded: {
      const value = parseInt(text().trim())
      root.acOnline = isNaN(value) ? -1 : value
    }
  }

  FileView {
    id: energyNowFile
    path: root.batteryPath ? (root.batteryPath + "/energy_now") : ""
    onLoaded: {
      const value = parseInt(text().trim())
      root.energyNow = isNaN(value) ? 0 : value
    }
  }

  FileView {
    id: energyFullFile
    path: root.batteryPath ? (root.batteryPath + "/energy_full") : ""
    onLoaded: {
      const value = parseInt(text().trim())
      root.energyFull = isNaN(value) ? 0 : value
    }
  }

  FileView {
    id: powerNowFile
    path: root.batteryPath ? (root.batteryPath + "/power_now") : ""
    onLoaded: {
      const value = parseInt(text().trim())
      root.powerNow = isNaN(value) ? 0 : value
    }
  }
}
