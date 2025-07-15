import QtQuick
import Quickshell

ShellRoot {
    Wlogout {
        id: wlogout

        Component.onCompleted: {
            wlogout.updateFocus(0);
        }

        Button {
            id: lockButton
            command: "quickshell -p ~/code/lockscreen/"
            keybind: Qt.Key_A
            text: "Lock"
            icon: "lock"
            command_text: "A"
            index: 0
            description_text: "Lock your Session"
        }

        Button {
            id: logoutButton
            command: "loginctl terminate-user $USER"
            keybind: Qt.Key_S
            text: "Logout"
            icon: "logout"
            command_text: "S"
            index: 1
            description_text: "End Current Session"
        }

        Button {
            id: rebootButton
            command: "systemctl reboot"
            keybind: Qt.Key_D
            text: "Reboot"
            icon: "reboot"
            command_text: "D"
            index: 2
            description_text: "Restart System"
        }

        Button {
            id: shutdownButton
            command: "systemctl poweroff"
            keybind: Qt.Key_F
            text: "Shutdown"
            icon: "shutdown"
            command_text: "F"
            index: 3
            description_text: "Power Off System"
        }
    }
}
