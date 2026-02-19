pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    property ListModel workspaces: ListModel {}
    property var windowsById: ({})
    property var windowsByWorkspaceId: ({})
    property var workspaceIdByWindowId: ({})
    property var workspaceAppIdsByIdx: ({})
    property var workspaceIconsByIdx: ({})

    function requestSnapshots() {
        if (!niriWorkspacesSnapshot.running) {
            niriWorkspacesSnapshot.running = true;
        }
        if (!niriWindowsSnapshot.running) {
            niriWindowsSnapshot.running = true;
        }
    }

    function normalizeWindowId(windowId) {
        if (windowId === null || windowId === undefined) {
            return "";
        }
        return String(windowId);
    }

    function appIdForWindow(windowId) {
        const normalizedWindowId = normalizeWindowId(windowId);
        if (!normalizedWindowId) {
            return "";
        }

        const windowInfo = windowsById[normalizedWindowId];
        return windowInfo && typeof windowInfo.appId === "string" ? windowInfo.appId : "";
    }

    function appIdForWorkspace(workspaceId) {
        if (workspaceId === null || workspaceId === undefined) {
            return "";
        }

        const workspaceIdKey = String(workspaceId);
        const appId = windowsByWorkspaceId[workspaceIdKey];
        return typeof appId === "string" ? appId : "";
    }

    function iconForAppId(rawAppId) {
        const appIcons = {
            "kitty": "fa_terminal.svg",
            "alacritty": "fa_terminal.svg",
            "ghostty": "fa_terminal.svg",
            "wezterm": "fa_terminal.svg",
            "org.wezfurlong.wezterm": "fa_terminal.svg",
            "org.kde.konsole": "fa_terminal.svg",
            "gnome-terminal": "fa_terminal.svg",
            "org.gnome.console": "fa_terminal.svg",
            "org.gnome.ptyxis": "fa_terminal.svg",
            "tilix": "fa_terminal.svg",
            "xfce4-terminal": "fa_terminal.svg",

            "vivaldi-stable": "fa_globe.svg",
            "vivaldi-snapshot": "fa_globe.svg",
            "firefox": "fa_globe.svg",
            "org.mozilla.firefox": "fa_globe.svg",
            "zen-browser": "fa_globe.svg",
            "floorp": "fa_globe.svg",
            "waterfox": "fa_globe.svg",
            "librewolf": "fa_globe.svg",
            "chromium": "fa_globe.svg",
            "google-chrome": "fa_globe.svg",
            "google-chrome-stable": "fa_globe.svg",
            "brave-browser": "fa_globe.svg",
            "microsoft-edge": "fa_globe.svg",
            "microsoft-edge-dev": "fa_globe.svg",
            "opera": "fa_globe.svg",
            "qutebrowser": "fa_globe.svg",
            "org.gnome.epiphany": "fa_globe.svg",
            "falkon": "fa_globe.svg",

            "discord": "fa_comment.svg",
            "vesktop": "fa_comment.svg",
            "slack": "fa_comment.svg",
            "telegram-desktop": "fa_comment.svg",
            "signal": "fa_comment.svg",
            "org.signal.signal": "fa_comment.svg",
            "element-desktop": "fa_comment.svg",
            "org.kde.neochat": "fa_comment.svg",
            "mattermost-desktop": "fa_comment.svg",
            "thunderbird": "fa_comment.svg",

            "code": "fa_dev.svg",
            "code-insiders": "fa_dev.svg",
            "code-oss": "fa_dev.svg",
            "vscodium": "fa_dev.svg",
            "zed": "fa_dev.svg",
            "nvim": "fa_dev.svg",
            "neovide": "fa_dev.svg",
            "emacs": "fa_dev.svg",
            "sublime_text": "fa_dev.svg",
            "jetbrains-idea": "fa_dev.svg",
            "jetbrains-pycharm": "fa_dev.svg",
            "jetbrains-webstorm": "fa_dev.svg",
            "jetbrains-goland": "fa_dev.svg",
            "jetbrains-clion": "fa_dev.svg",
            "android-studio": "fa_dev.svg",

            "obsidian": "fa_note_sticky.svg"
        };

        const keywordIcons = [
            { icon: "fa_terminal.svg", keywords: ["kitty", "alacritty", "wezterm", "ghostty", "konsole", "terminal", "xterm", "urxvt", "tilix", "ptyxis"] },
            { icon: "fa_globe.svg", keywords: ["firefox", "vivaldi", "chrome", "chromium", "brave", "browser", "opera", "edge", "librewolf", "qutebrowser", "epiphany", "falkon", "waterfox", "floorp", "zen"] },
            { icon: "fa_comment.svg", keywords: ["discord", "vesktop", "telegram", "signal", "slack", "element", "mattermost", "chat", "thunderbird", "mail"] },
            { icon: "fa_dev.svg", keywords: ["code", "codium", "jetbrains", "idea", "pycharm", "webstorm", "goland", "clion", "rider", "android-studio", "zed", "nvim", "neovide", "vim", "emacs", "sublime", "dev"] },
            { icon: "fa_note_sticky.svg", keywords: ["obsidian", "logseq", "joplin", "notes", "notion", "zettlr"] }
        ];

        const appId = typeof rawAppId === "string" ? rawAppId.trim().toLowerCase().replace(/\.desktop$/, "") : "";
        if (!appId) {
            return "fa_plus.svg";
        }
        if (appIcons[appId]) {
            return appIcons[appId];
        }
        for (const rule of keywordIcons) {
            for (const keyword of rule.keywords) {
                if (appId.includes(keyword)) {
                    return rule.icon;
                }
            }
        }

        return "fa_plus.svg";
    }

    function appIdForWorkspaceDirect(workspaceId) {
        // Scan all known windows for one that belongs to this workspace.
        // This is the most reliable path since it doesn't depend on activeWindowId
        // being set correctly in the workspace snapshot.
        const wsIdKey = String(workspaceId);
        for (const windowId of Object.keys(windowsById)) {
            const win = windowsById[windowId];
            if (win.workspaceId === wsIdKey) {
                return win.appId;
            }
        }
        return "";
    }

    function refreshWorkspaceAppIds() {
        const nextWorkspaceAppIdsByIdx = {};
        const nextWorkspaceIconsByIdx = {};
        for (let i = 0; i < workspaces.count; i++) {
            const value = workspaces.get(i);
            const activeWindowId = normalizeWindowId(value.activeWindowId);
            const appId = appIdForWindow(activeWindowId)
                       || appIdForWorkspace(value.id)
                       || appIdForWorkspaceDirect(value.id);
            const idKey = String(value.id);
            const icon = iconForAppId(appId);
            workspaces.set(i, {
                id: value.id,
                idx: value.idx,
                isActive: value.isActive,
                name: typeof value.name === "string" ? value.name : "",
                output: typeof value.output === "string" ? value.output : "",
                activeWindowId: activeWindowId,
                appId: appId
            });
            nextWorkspaceAppIdsByIdx[idKey] = appId;
            nextWorkspaceIconsByIdx[idKey] = icon;
        }
        workspaceAppIdsByIdx = nextWorkspaceAppIdsByIdx;
        workspaceIconsByIdx = nextWorkspaceIconsByIdx;
    }

    function updateWindows(windowsEvent) {
        const nextWindowsById = {};
        const nextWindowsByWorkspaceId = {};
        const nextWorkspaceIdByWindowId = {};
        for (const window of windowsEvent.windows) {
            const windowId = window ? normalizeWindowId(window.id) : "";
            if (!windowId) {
                continue;
            }

            const appId = typeof window.app_id === "string" ? window.app_id : "";
            const workspaceId = window && window.workspace_id !== undefined && window.workspace_id !== null ? String(window.workspace_id) : "";

            nextWindowsById[windowId] = { appId: appId, workspaceId: workspaceId };

            if (workspaceId) {
                nextWorkspaceIdByWindowId[windowId] = workspaceId;
                if (!nextWindowsByWorkspaceId[workspaceId] || window.is_focused) {
                    nextWindowsByWorkspaceId[workspaceId] = appId;
                }
            }
        }

        // For any workspace whose active window has no workspace_id in the payload
        // (common for the focused workspace on some niri versions), fill it in via activeWindowId.
        for (let i = 0; i < workspaces.count; i++) {
            const ws = workspaces.get(i);
            const wsActiveWindowId = normalizeWindowId(ws.activeWindowId);
            if (wsActiveWindowId && nextWindowsById[wsActiveWindowId]) {
                const wsIdKey = String(ws.id);
                if (!nextWindowsByWorkspaceId[wsIdKey]) {
                    nextWindowsByWorkspaceId[wsIdKey] = nextWindowsById[wsActiveWindowId].appId;
                }
            }
        }

        windowsById = nextWindowsById;
        windowsByWorkspaceId = nextWindowsByWorkspaceId;
        workspaceIdByWindowId = nextWorkspaceIdByWindowId;
        refreshWorkspaceAppIds();
    }

    function updateWorkspaces(workspacesEvent) {
        const sortedWorkspaces = workspacesEvent.workspaces;
        sortedWorkspaces.sort((a, b) => parseInt(a.id) - parseInt(b.id));
        workspaces.clear();
        for (const workspace of sortedWorkspaces) {
            const workspaceName = typeof workspace.name === "string" ? workspace.name : "";
            const workspaceOutput = typeof workspace.output === "string" ? workspace.output : "";
            const activeWindowId = normalizeWindowId(workspace.active_window_id);
            const appId = appIdForWindow(activeWindowId) || appIdForWorkspace(workspace.id);
            workspaces.append({
                id: workspace.id,
                idx: workspace.idx,
                isActive: workspace.is_active,
                name: workspaceName,
                output: workspaceOutput,
                activeWindowId: activeWindowId,
                appId: appId
            });
        }
        refreshWorkspaceAppIds();
        // Ensure window data is fresh so icons resolve correctly (especially workspace 1 on startup).
        if (!niriWindowsSnapshot.running) {
            niriWindowsSnapshot.running = true;
        }
    }

    function activateWorkspace(workspacesEvent) {
        let activatedWorkspace = null;

        for (let i = 0; i < workspaces.count; i++) {
            const value = workspaces.get(i);
            if (value.id == workspacesEvent.id) {
                activatedWorkspace = value;
                break;
            }
        }

        if (!activatedWorkspace) {
            return;
        }

        for (let i = 0; i < workspaces.count; i++) {
            const value = workspaces.get(i);
            if (value.output === activatedWorkspace.output) {
                workspaces.set(i, {
                    id: value.id,
                    idx: value.idx,
                    isActive: value.id === activatedWorkspace.id,
                    name: typeof value.name === "string" ? value.name : "",
                    output: typeof value.output === "string" ? value.output : "",
                    activeWindowId: normalizeWindowId(value.activeWindowId),
                    appId: typeof value.appId === "string" ? value.appId : ""
                });
            }
        }
        refreshWorkspaceAppIds();
    }

    Component.onCompleted: {
        requestSnapshots();
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            requestSnapshots();
        }
    }

    Process {
        id: niriWorkspacesSnapshot
        running: false
        command: ["niri", "msg", "--json", "workspaces"]

        stdout: SplitParser {
            onRead: data => {
                try {
                    const snapshot = JSON.parse(data.trim());
                    if (Array.isArray(snapshot)) {
                        updateWorkspaces({ workspaces: snapshot });
                    }
                } catch (e) {
                    console.log(e);
                }
            }
        }
    }

    Process {
        id: niriWindowsSnapshot
        running: false
        command: ["niri", "msg", "--json", "windows"]

        stdout: SplitParser {
            onRead: data => {
                try {
                    const snapshot = JSON.parse(data.trim());
                    if (Array.isArray(snapshot)) {
                        updateWindows({ windows: snapshot });
                    }
                } catch (e) {
                    console.log(e);
                }
            }
        }
    }

    Process {
        id: niriEvents
        running: true
        command: ["niri", "msg", "--json", "event-stream"]

        stdout: SplitParser {
            onRead: data => {
                try {
                    const event = JSON.parse(data.trim());
                    if (event.WorkspacesChanged) {
                        updateWorkspaces(event.WorkspacesChanged);
                    }
                    if (event.WindowsChanged) {
                        updateWindows(event.WindowsChanged);
                    }
                    if (event.WorkspaceActivated) {
                        activateWorkspace(event.WorkspaceActivated);
                    }
                    if (event.WindowFocusChanged) {
                        // A window gaining focus may change the icon for its workspace.
                        // Re-sync window data to pick up the new focus state.
                        if (!niriWindowsSnapshot.running) {
                            niriWindowsSnapshot.running = true;
                        }
                    }
                } catch (e) {
                    console.log(e);
                }
            }
        }
    }
}
