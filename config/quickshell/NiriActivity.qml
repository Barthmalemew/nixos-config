import QtQuick
import Quickshell.Io
import "theme" as Theme

// Watches niri state to determine whether the currently focused workspace
// has any windows. Used to show/hide UI elements (like a top bar) only when
// you're "working" on a populated workspace.
Item {
    id: root

    property bool active: true

    // Derived state
    property int focusedWorkspaceId: -1
    property int focusedWindowCount: 0
    readonly property bool hasWindows: focusedWindowCount > 0

    Theme.Colors { id: colors }

    property var _workspaces: []
    property var _windows: []

    function _unwrap(obj) {
        if (!obj) return null;
        if (obj.Ok !== undefined) return obj.Ok;
        if (obj.Err !== undefined) return null;
        return obj;
    }

    function _findArray(obj, key) {
        if (!obj || typeof obj !== "object") return null;
        if (obj[key] && Array.isArray(obj[key])) return obj[key];
        for (const k in obj) {
            const v = obj[k];
            if (!v || typeof v !== "object") continue;
            const found = _findArray(v, key);
            if (found) return found;
        }
        return null;
    }

    function _extractWorkspaces(obj) {
        const v = _unwrap(obj);
        // Common shapes: { workspaces: [...] } nested under an event
        const ws = _findArray(v, "workspaces");
        return ws || null;
    }

    function _extractWindows(obj) {
        const v = _unwrap(obj);
        const wins = _findArray(v, "windows");
        return wins || null;
    }

    function _getFocusedWorkspaceId(workspaces) {
        if (!Array.isArray(workspaces)) return -1;
        for (let i = 0; i < workspaces.length; i++) {
            const w = workspaces[i] || {};
            const focused = w.is_focused ?? w.isFocused ?? w.focused ?? false;
            if (!focused) continue;
            const id = w.id ?? w.workspace_id ?? w.workspaceId ?? -1;
            return typeof id === "number" ? id : parseInt(String(id), 10);
        }
        return -1;
    }

    function _countWindowsInWorkspace(windows, workspaceId) {
        if (!Array.isArray(windows) || workspaceId < 0) return 0;
        let n = 0;
        for (let i = 0; i < windows.length; i++) {
            const win = windows[i] || {};
            const wid = win.workspace_id ?? win.workspaceId ?? win.workspace ?? -1;
            const idNum = typeof wid === "number" ? wid : parseInt(String(wid), 10);
            if (idNum === workspaceId) n++;
        }
        return n;
    }

    function _recompute() {
        const focusedId = _getFocusedWorkspaceId(_workspaces);
        focusedWorkspaceId = focusedId;
        const count = _countWindowsInWorkspace(_windows, focusedId);
        focusedWindowCount = count;
    }

    // --- Event stream (preferred): low overhead + responsive
    Process {
        id: eventStream
        command: [colors.niriBin, "msg", "--json", "event-stream"]
        stdout: SplitParser {
            onRead: data => {
                const text = (data || "").trim();
                if (!text) return;
                const lines = text.split("\n");
                for (let i = 0; i < lines.length; i++) {
                    const line = lines[i].trim();
                    if (!line) continue;
                    let msg = null;
                    try { msg = JSON.parse(line); } catch (e) { continue; }
                    const ws = root._extractWorkspaces(msg);
                    if (ws) root._workspaces = ws;
                    const wins = root._extractWindows(msg);
                    if (wins) root._windows = wins;
                    root._recompute();
                }
            }
        }
        onExited: {
            // Event stream can fail if NIRI_SOCKET isn't in the environment.
            // Fallback polling will keep the UI functional.
            pollTimer.running = root.active;
        }
    }

    // --- Fallback polling
    Timer {
        id: pollTimer
        interval: 750
        repeat: true
        running: false
        onTriggered: {
            if (!root.active) return;
            if (eventStream.running) return;
            workspacesReq.running = true;
            windowsReq.running = true;
        }
    }

    Process {
        id: workspacesReq
        command: [colors.niriBin, "msg", "--json", "workspaces"]
        stdout: SplitParser {
            onRead: data => {
                let msg = null;
                try { msg = JSON.parse((data || "").trim()); } catch (e) { return; }
                const ws = root._extractWorkspaces(msg);
                if (ws) root._workspaces = ws;
                root._recompute();
            }
        }
    }

    Process {
        id: windowsReq
        command: [colors.niriBin, "msg", "--json", "windows"]
        stdout: SplitParser {
            onRead: data => {
                let msg = null;
                try { msg = JSON.parse((data || "").trim()); } catch (e) { return; }
                const wins = root._extractWindows(msg);
                if (wins) root._windows = wins;
                root._recompute();
            }
        }
    }

    Component.onCompleted: {
        if (!root.active) return;
        eventStream.running = true;
        // Kick a poll until the stream feeds initial state.
        pollTimer.running = true;
    }
}
