import QtQuick
import Quickshell.Io

Rectangle {
    id: button

    required property string text
    required property string icon
    required property string command
    required property string command_text
    required property string description_text
    required property int index

    property var keybind: null
    property bool isFocused: false
    property bool isEnabled: true

    readonly property var process: Process {
        command: ["sh", "-c", button.command]
    }

    function exec() {
        if (isEnabled) {
            console.log(`Executing command: ${command}`);
            process.startDetached();
            Qt.quit();
        }
    }

    border {
        width: isFocused ? .5 : 0
        color: isFocused ? "#fff" : "transparent"
    }

    Behavior on border.width {
        NumberAnimation {
            duration: 150
        }
    }

    Accessible.role: Accessible.Button
    Accessible.name: text
    Accessible.description: description_text
    Accessible.onPressAction: exec()
}
