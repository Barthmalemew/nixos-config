import QtQuick
import QtQuick.Layouts
import qs.Services
import qs.Config

ColumnLayout {
    spacing: 2

    Text {
        color: Colorscheme.gold
        text: (Time.month + " " + Time.day).toUpperCase()
        font.pixelSize: 14
        font.bold: true
        font.family: "JetBrainsMono Nerd Font"
    }

    Text {
        color: Colorscheme.gold
        text: Time.hours
        font.pixelSize: 104
        font.bold: true
        font.family: "JetBrainsMono Nerd Font"
    }

    Text {
        leftPadding: 70
        color: Colorscheme.gold
        text: Time.minutes
        font.pixelSize: 84
        font.bold: true
        font.family: "JetBrainsMono Nerd Font"
    }
}
