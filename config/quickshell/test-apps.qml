import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    Component.onCompleted: {
        console.log("App count:", DesktopEntries.applications.count);
        if (DesktopEntries.applications.count > 0) {
            console.log("First app:", DesktopEntries.applications.applications[0].name); // Try array access if property exists?
             // Or try get
             try {
                 console.log("Get(0):", DesktopEntries.applications.get(0).name);
             } catch(e) {
                 console.log("get(0) failed");
             }
        }
        Qt.quit();
    }
}
