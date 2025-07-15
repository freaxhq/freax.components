import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "root:/config"

PanelWindow {
    id: root

    readonly property int barMargin: 8
    readonly property int barHeight: 42
    readonly property int barRadius: 21
    readonly property int itemSpacing: 8
    readonly property int widgetPadding: 12
    readonly property int widgetRadius: 12

    readonly property color barBgColor: Qt.rgba(0.1, 0.1, 0.12, 0.97)
    readonly property color barWorkspaceColor: Qt.rgba(0.15, 0.15, 0.17, 0.8)
    readonly property color barWorkspaceColorActive: Qt.rgba(0.3, 0.6, 1.0, 0.9)
    readonly property color barWorkspaceColorHovered: Qt.rgba(0.2, 0.2, 0.22, 0.9)
    readonly property color barTextColor: Qt.rgba(1, 1, 1, 0.9)
    readonly property color barTextColorSecondary: Qt.rgba(1, 1, 1, 0.7)
    readonly property color barAccentColor: Qt.rgba(0.4, 0.8, 1.0, 1.0)
    readonly property color barWarningColor: Qt.rgba(1.0, 0.6, 0.2, 1.0)
    readonly property color barErrorColor: Qt.rgba(1.0, 0.3, 0.3, 1.0)

    anchors {
        bottom: true
        left: true
        right: true
    }

    margins {
        left: barMargin
        right: barMargin
        bottom: barMargin
    }

    implicitHeight: barHeight
    color: "transparent"

    Rectangle {
        id: mainBar
        anchors.fill: parent
        color: root.barBgColor
        radius: root.barRadius

        border.color: Qt.rgba(1, 1, 1, 0.1)
        border.width: 1

        Rectangle {
            id: leftSection
            anchors {
                left: parent.left
                leftMargin: root.widgetPadding
                verticalCenter: parent.verticalCenter
            }
            width: leftContent.width
            height: parent.height - 8
            color: "transparent"

            Row {
                id: leftContent
                anchors.verticalCenter: parent.verticalCenter
                spacing: root.itemSpacing

                Repeater {
                    model: Hyprland.workspaces

                    Rectangle {
                        id: workspaceButton
                        property bool isActive: modelData.active
                        property bool isHovered: workspaceMouseArea.containsMouse

                        color: isActive ? barWorkspaceColorActive : isHovered ? barWorkspaceColorHovered : barWorkspaceColor
                        radius: root.widgetRadius
                        height: 24
                        width: isActive ? 32 : 28

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }

                        Behavior on width {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            color: "transparent"
                            border.color: isActive ? barAccentColor : "transparent"
                            border.width: 2
                            opacity: isActive ? 0.6 : 0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 200
                                }
                            }
                        }

                        MouseArea {
                            id: workspaceMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: Hyprland.dispatch(`workspace ${modelData.id.toString()}`)
                            cursorShape: Qt.PointingHandCursor
                        }

                        Text {
                            text: modelData.name
                            anchors.centerIn: parent
                            color: workspaceButton.isActive ? "white" : barTextColor
                            font.pointSize: 10
                            font.weight: workspaceButton.isActive ? Font.Bold : Font.Medium
                        }
                    }
                }

                Rectangle {
                    id: windowTitleContainer
                    height: 26
                    width: Math.max(windowTitleText.contentWidth + 16, 0)
                    color: Qt.rgba(0.2, 0.2, 0.22, 0.6)
                    radius: root.widgetRadius

                    Text {
                        id: windowTitleText
                        text: "visible"
                        color: barTextColorSecondary
                        font.pointSize: 10
                        font.weight: Font.DemiBold
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: 8
                            right: parent.right
                            rightMargin: 8
                        }
                    }

                    Behavior on width {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            Connections {
                target: Hyprland
                function onRawEvent(event: HyprlandEvent): void {
                    if (!event.name.endsWith("v2"))
                        getActiveClient.running = true;
                }
            }

            Process {
                id: getActiveClient
                command: ["hyprctl", "activewindow", "-j"]
                stdout: StdioCollector {
                    onStreamFinished: () => {
                        try {
                            const out = JSON.parse(this.text);
                            let hyprTitle = out.title;

                            if (hyprTitle == undefined || hyprTitle === "") {
                                windowTitleText.text = "";
                                return;
                            }

                            if (hyprTitle.startsWith("nvim") || hyprTitle.includes("vim")) {
                                windowTitleText.text = "󰕷 " + hyprTitle.split(" ")[0];
                            } else if (hyprTitle.startsWith("Firefox")) {
                                windowTitleText.text = "󰈹 Firefox";
                            } else if (hyprTitle.includes("Chrome")) {
                                windowTitleText.text = "󰊯 Chrome";
                            } else if (hyprTitle.includes("terminal") || hyprTitle.includes("Terminal")) {
                                windowTitleText.text = " Terminal";
                            } else {
                                if (hyprTitle.length > 40) {
                                    hyprTitle = hyprTitle.substring(0, 37) + "...";
                                }
                                windowTitleText.text = hyprTitle;
                            }
                        } catch (e) {
                            console.log(e);
                            windowTitleText.text = "error";
                        }
                    }
                }
            }
        }

        Rectangle {
            id: centerSection
            anchors.centerIn: parent
            width: 100
            height: parent.height - 12
            color: Qt.rgba(0.15, 0.15, 0.17, 0.8)
            radius: root.widgetRadius

            SystemClock {
                id: clock
                precision: SystemClock.Seconds
            }

            Rectangle {
                id: centerContent
                anchors.fill: parent

                color: "transparent"

                Text {
                    id: timeText
                    text: {
                        let hours = clock.date.getHours();
                        const minutes = clock.date.getMinutes().toString().padStart(2, '0');
                        const ampm = hours >= 12 ? 'PM' : 'AM';
                        hours = hours % 12;
                        hours = hours ? hours : 12;
                        const hoursStr = hours.toString().padStart(2, '0');
                        return `${hoursStr}:${minutes} ${ampm}`;
                    }
                    font.pointSize: 12
                    font.weight: Font.DemiBold
                    color: barTextColor
                    font.letterSpacing: 0.5
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Rectangle {
            id: rightSection
            anchors {
                right: parent.right
                rightMargin: root.widgetPadding
                verticalCenter: parent.verticalCenter
            }
            width: rightContent.width
            height: parent.height - 8
            color: "transparent"

            Row {
                id: rightContent
                anchors.verticalCenter: parent.verticalCenter
                spacing: root.itemSpacing

                Rectangle {
                    id: cpuWidget
                    height: 30
                    width: cpuContent.width + 16
                    color: Qt.rgba(0.15, 0.15, 0.17, 0.8)
                    radius: root.widgetRadius

                    Row {
                        id: cpuContent
                        anchors.centerIn: parent
                        spacing: 6

                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: getCpuColor(parseFloat(cpuUsageText.cpuUsageValue))
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            id: cpuUsageText
                            property real cpuUsageValue: 0
                            font.pointSize: 10
                            font.weight: Font.Medium
                            color: barTextColor
                            text: "CPU " + Math.round(cpuUsageValue) + "%"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Timer {
                        running: true
                        repeat: true
                        interval: 2000
                        onTriggered: cpuInfo.running = true
                    }

                    Process {
                        id: cpuInfo
                        command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | awk -F'%' '{print $1}'"]
                        running: false

                        stdout: SplitParser {
                            onRead: data => {
                                let usage = parseFloat(data.trim());
                                if (!isNaN(usage)) {
                                    cpuUsageText.cpuUsageValue = usage;
                                }
                                cpuInfo.running = false;
                            }
                        }
                    }
                }

                Rectangle {
                    id: memoryWidget
                    height: 30
                    width: memoryContent.width + 16
                    color: Qt.rgba(0.15, 0.15, 0.17, 0.8)
                    radius: root.widgetRadius

                    Row {
                        id: memoryContent
                        anchors.centerIn: parent
                        spacing: 6

                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: getMemoryColor(parseFloat(memoryUsageText.memoryUsageValue))
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            id: memoryUsageText
                            property real memoryUsageValue: 0
                            font.pointSize: 10
                            font.weight: Font.Medium
                            color: barTextColor
                            text: "RAM " + Math.round(memoryUsageValue) + "%"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Timer {
                        running: true
                        repeat: true
                        interval: 3000
                        onTriggered: memoryInfo.running = true
                    }

                    Process {
                        id: memoryInfo
                        command: ["sh", "-c", "free | grep Mem | awk '{printf \"%.1f\", $3/$2 * 100.0}'"]
                        running: false

                        stdout: SplitParser {
                            onRead: data => {
                                let usage = parseFloat(data.trim());
                                if (!isNaN(usage)) {
                                    memoryUsageText.memoryUsageValue = usage;
                                }
                                memoryInfo.running = false;
                            }
                        }
                    }
                }

                Rectangle {
                    id: tempWidget
                    height: 30
                    width: tempContent.width + 16
                    color: Qt.rgba(0.15, 0.15, 0.17, 0.8)
                    radius: root.widgetRadius

                    Row {
                        id: tempContent
                        anchors.centerIn: parent
                        spacing: 6

                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: getTempColor(parseFloat(tempText.tempValue))
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            id: tempText
                            property real tempValue: 0
                            font.pointSize: 10
                            font.weight: Font.Medium
                            color: barTextColor
                            text: Math.round(tempValue) + "°C"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Timer {
                        running: true
                        repeat: true
                        interval: 5000
                        onTriggered: tempInfo.running = true
                    }

                    Process {
                        id: tempInfo
                        command: ["sh", "-c", "sensors | grep -i 'Package id 0' | awk '{print $4}' | sed 's/+//g' | sed 's/°C//g' || sensors | grep -i 'Tctl' | awk '{print $2}' | sed 's/+//g' | sed 's/°C//g' || echo '0'"]
                        running: false

                        stdout: SplitParser {
                            onRead: data => {
                                let temp = parseFloat(data.trim());
                                if (!isNaN(temp)) {
                                    tempText.tempValue = temp;
                                }
                                tempInfo.running = false;
                            }
                        }
                    }
                }

                Rectangle {
                    id: systemTrayWidget
                    height: 30
                    width: trayContent.width + 16
                    color: Qt.rgba(0.15, 0.15, 0.17, 0.8)
                    radius: root.widgetRadius

                    Row {
                        id: trayContent
                        anchors.centerIn: parent
                        spacing: 4

                        Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            color: barAccentColor
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            color: barAccentColor
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            color: barAccentColor
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            console.log("System tray clicked");
                        }
                    }
                }
            }
        }
    }

    function getCpuColor(usage) {
        if (usage < 30)
            return barAccentColor;
        if (usage < 70)
            return barWarningColor;
        return barErrorColor;
    }

    function getMemoryColor(usage) {
        if (usage < 50)
            return barAccentColor;
        if (usage < 80)
            return barWarningColor;
        return barErrorColor;
    }

    function getTempColor(temp) {
        if (temp < 50)
            return barAccentColor;
        if (temp < 75)
            return barWarningColor;
        return barErrorColor;
    }
}
