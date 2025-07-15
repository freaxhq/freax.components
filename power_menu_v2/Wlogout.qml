import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick.Effects
import "root:/config"

Variants {
    id: root

    property color backgroundColor: "#e60c0c0c"
    property color buttonColor: Config.colorschemes.batman.base08
    property color buttonBorderColor: "#DCD7BA"
    property color buttonHoverColor: "#54546D"
    property color buttonTextColor: "#9CABCA"
    property color shortcutTextColor: "#fff"
    property color shortcutTextBorderColor: "#fff"
    property color focusedBorderColor: Config.colorschemes.batman.base17
    property int focusedIndex: 0
    property var buttonItems: []

    default property list<Button> buttons
    model: Quickshell.screens

    function updateFocus(newIndex) {
        if (newIndex >= 0 && newIndex < buttons.length) {
            focusedIndex = newIndex;

            for (let i = 0; i < buttonItems.length; i++) {
                if (buttonItems[i]) {
                    buttonItems[i].isFocused = (i === focusedIndex);
                }
            }
        }
    }

    function navigateUp() {
        let newIndex = focusedIndex;
        if (focusedIndex >= 2) {
            newIndex = focusedIndex - 2;
        }
        updateFocus(newIndex);
    }

    function navigateDown() {
        let newIndex = focusedIndex;
        if (focusedIndex < 2) {
            newIndex = focusedIndex + 2;
        }
        updateFocus(newIndex);
    }

    function navigateLeft() {
        let newIndex = focusedIndex;
        if (focusedIndex % 2 === 1) {
            newIndex = focusedIndex - 1;
        }
        updateFocus(newIndex);
    }

    function navigateRight() {
        let newIndex = focusedIndex;
        if (focusedIndex % 2 === 0) {
            newIndex = focusedIndex + 1;
        }
        updateFocus(newIndex);
    }

    function navigateNext() {
        let newIndex = (focusedIndex + 1) % buttons.length;
        updateFocus(newIndex);
    }

    function navigatePrevious() {
        let newIndex = (focusedIndex - 1 + buttons.length) % buttons.length;
        updateFocus(newIndex);
    }

    function executeFocusedButton() {
        if (focusedIndex >= 0 && focusedIndex < buttons.length) {
            buttons[focusedIndex].exec();
        }
    }

    PanelWindow {
        id: window

        property var modelData
        screen: modelData
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        color: "transparent"

        contentItem {
            focus: true
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape || event.key === Qt.Key_Q) {
                    Qt.quit();
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                    executeFocusedButton();
                } else if (event.key === Qt.Key_Up) {
                    navigateUp();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Down) {
                    navigateDown();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Left) {
                    navigateLeft();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Right) {
                    navigateRight();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Tab) {
                    if (event.modifiers & Qt.ShiftModifier) {
                        navigatePrevious();
                    } else {
                        navigateNext();
                    }
                    event.accepted = true;
                } else if (event.key === Qt.Key_Backtab) {
                    navigatePrevious();
                    event.accepted = true;
                } else {
                    for (let i = 0; i < buttons.length; i++) {
                        let button = buttons[i];
                        if (event.key === button.keybind) {
                            button.exec();
                            event.accepted = true;
                            break;
                        }
                    }
                }
            }
        }

        anchors {
            top: true
            bottom: true
            right: true
            left: true
        }

        Rectangle {
            color: backgroundColor
            anchors.fill: parent

            MouseArea {
                anchors.fill: parent
                onClicked: Qt.quit()

                Rectangle {
                    width: Config.sizess.width
                    height: Config.sizess.height

                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: "black"
                        }
                        GradientStop {
                            position: 0.6
                            color: "#1a1818"
                        }
                        GradientStop {
                            position: 1.0
                            color: "black"
                        }
                    }

                    radius: 20

                    anchors {
                        verticalCenter: parent.verticalCenter
                        horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        id: titleText
                        text: qsTr("System Control")
                        font.pointSize: 20
                        font.bold: true
                        font.letterSpacing: 2.0
                        color: "white"

                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: parent.top
                            topMargin: 20
                        }
                    }

                    Text {
                        id: hintText
                        text: qsTr("Use arrow keys, Tab, or shortcuts to navigate")
                        font.pointSize: 12
                        color: "gray"
                        opacity: 0.8

                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: titleText.bottom
                            topMargin: 5
                        }
                    }

                    GridLayout {
                        property real gridSizePercentage: 0.9
                        property int gridDimensions: 500
                        property int gridSpacing: 25

                        width: gridDimensions * gridSizePercentage
                        height: gridDimensions * gridSizePercentage

                        columns: 2
                        rowSpacing: gridSpacing + 5
                        columnSpacing: gridSpacing

                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: hintText.bottom
                            topMargin: 25
                        }

                        Repeater {
                            model: buttons
                            delegate: Rectangle {
                                id: actionRect
                                required property Button modelData
                                property bool isFocused: modelData.index === focusedIndex
                                property bool isHovered: ma.containsMouse

                                Component.onCompleted: {
                                    if (buttonItems.length <= modelData.index) {
                                        buttonItems.length = modelData.index + 1;
                                    }
                                    buttonItems[modelData.index] = actionRect;
                                }

                                color: {
                                    if (modelData.index === 0)
                                        return "#3C362B";
                                    if (modelData.index === 1)
                                        return "#2b3a3b";
                                    if (modelData.index === 2)
                                        return "#3A2E30";
                                    if (modelData.index === 3)
                                        return "#2B1F2F";
                                    return "salmon";
                                }

                                border {
                                    width: isFocused ? .61 : 0.7
                                    color: isFocused ? focusedBorderColor : "#5D4C1D"
                                }

                                radius: 30

                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                Rectangle {
                                    anchors.fill: parent
                                    color: "transparent"
                                    border.color: focusedBorderColor
                                    border.width: 1
                                    radius: 30
                                    opacity: isFocused ? 0.3 : 0

                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration: 150
                                        }
                                    }
                                }

                                MouseArea {
                                    id: ma
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        updateFocus(modelData.index);
                                        modelData.exec();
                                    }
                                    onEntered: {
                                        updateFocus(modelData.index);
                                    }
                                }

                                Rectangle {
                                    anchors {
                                        top: parent.top
                                        right: parent.right
                                        topMargin: 10
                                        rightMargin: 20
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        color: "#fff"
                                        opacity: isFocused ? 0.25 : 0.15
                                        radius: 10

                                        Behavior on opacity {
                                            NumberAnimation {
                                                duration: 150
                                            }
                                        }
                                    }

                                    color: "transparent"
                                    width: parent.width * 0.19
                                    height: parent.height * 0.17

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.command_text + " ⏎"
                                        color: shortcutTextColor
                                        opacity: isFocused ? 1.0 : 0.95
                                        font.pointSize: 10
                                        font.bold: true

                                        Behavior on opacity {
                                            NumberAnimation {
                                                duration: 150
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    id: iconRectangle
                                    anchors {
                                        horizontalCenter: actionRect.horizontalCenter
                                        top: parent.top
                                        topMargin: 50
                                    }

                                    Image {
                                        id: bg_image_of_icon
                                        source: `assets/${modelData.index}.png`
                                        anchors.fill: parent
                                    }

                                    MultiEffect {
                                        id: multi_effect_bs_icon
                                        source: bg_image_of_icon
                                        anchors.fill: bg_image_of_icon
                                        blurEnabled: true
                                        blurMax: 64
                                        blur: isHovered || isFocused ? 1 : 0.5

                                        Behavior on blur {
                                            NumberAnimation {
                                                duration: 200
                                            }
                                        }
                                    }

                                    width: parent.width * 0.4
                                    height: parent.height * 0.4
                                    radius: 20
                                    color: "transparent"

                                    scale: (isHovered || isFocused) ? 1.1 : 1.0

                                    Behavior on scale {
                                        NumberAnimation {
                                            duration: 200
                                            easing.type: Easing.InOutQuad
                                        }
                                    }

                                    Image {
                                        id: iconImage
                                        source: `icons_white/${modelData.icon}.svg`
                                        width: parent.width * 0.6
                                        height: parent.height * 0.6
                                        anchors.centerIn: parent

                                        scale: (isHovered || isFocused) ? 1.1 : 1.0

                                        Behavior on scale {
                                            NumberAnimation {
                                                duration: 200
                                                easing.type: Easing.InOutQuad
                                            }
                                        }
                                    }

                                    Text {
                                        id: buttonTitleText
                                        text: qsTr(`${modelData.text}`)
                                        font.bold: true
                                        font.pointSize: 14
                                        color: "white"
                                        font.letterSpacing: 2
                                        opacity: isFocused ? 1.0 : 0.9

                                        anchors {
                                            horizontalCenter: parent.horizontalCenter
                                            top: parent.bottom
                                            topMargin: 12
                                        }

                                        Behavior on opacity {
                                            NumberAnimation {
                                                duration: 150
                                            }
                                        }
                                    }

                                    Text {
                                        id: buttonDescText
                                        text: qsTr(`${modelData.description_text}`)
                                        font.pointSize: 11
                                        font.weight: 600
                                        color: "gray"
                                        opacity: isFocused ? 1.0 : 0.8

                                        anchors {
                                            horizontalCenter: parent.horizontalCenter
                                            top: buttonTitleText.bottom
                                            topMargin: 2
                                        }

                                        Behavior on opacity {
                                            NumberAnimation {
                                                duration: 150
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
