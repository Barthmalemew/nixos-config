pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    property ListModel workspaces: ListModel {}

    function updateWorkspaces(workspacesEvent) {
        const sortedWorkspaces = workspacesEvent.workspaces;
        sortedWorkspaces.sort((a, b) => parseInt(a.id) - parseInt(b.id));
        workspaces.clear();
        for (const workspace of sortedWorkspaces) {
            const workspaceName = typeof workspace.name === "string" ? workspace.name : "";
            const workspaceOutput = typeof workspace.output === "string" ? workspace.output : "";
            workspaces.append({
                id: workspace.id,
                idx: workspace.idx,
                isActive: workspace.is_active,
                name: workspaceName,
                output: workspaceOutput
            });
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
                    output: typeof value.output === "string" ? value.output : ""
                });
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
                    } else if (event.WorkspaceActivated) {
                        activateWorkspace(event.WorkspaceActivated);
                    }
                } catch (e) {
                    console.log(e);
                }
            }
        }
    }
}
