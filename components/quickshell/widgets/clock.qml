import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: clockWidget
    width: 200
    height: 60
    color: "#1e1e1e"
    radius: 8
    
    property string timeFormat: "hh:mm:ss"
    property color textColor: "#ffffff"
    property int fontSize: 16
    
    Text {
        anchors.centerIn: parent
        text: Qt.formatTime(new Date(), timeFormat)
        color: textColor
        font.pixelSize: fontSize
    }
    
    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: parent.children[0].text = Qt.formatTime(new Date(), timeFormat)
    }
}
