import QtQuick
import QtQuick.Layouts
import qs.Services
import qs.Config

Rectangle {
    implicitWidth: content.width + 6
    implicitHeight: content.height + 6
    radius: Size.borderRadiusSmall
    color: Colorscheme.overlay
    border.width: 1
    border.color: Colorscheme.love

    ColumnLayout {
        id: content
        anchors.centerIn: parent
        spacing: 6
        Repeater {
            model: Niri.workspaces
            delegate: WorkspaceItem {}
        }
    }
}
