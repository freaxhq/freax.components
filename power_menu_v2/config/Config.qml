pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property Sizess sizess: Sizess {}
    readonly property Colorschems colorschemes: Colorschems {}

    component Sizess: QtObject {
        readonly property int width: 550
        readonly property int height: 650
    }

    component Colorschems: QtObject {
        readonly property Batman batman: Batman {}
    }

    component Batman: QtObject {
        readonly property color base00: "#1b1d1e"
        readonly property color base01: "#1b1d1e"
        readonly property color base02: "#505354"
        readonly property color base03: "#6d6f6e"
        readonly property color base04: "#8a8c89"
        readonly property color base05: "#a7a8a3"
        readonly property color base06: "#c5c5be"
        readonly property color base07: "#dadad5"
        readonly property color base08: "#e6db43"
        readonly property color base09: "#f3fd21"
        readonly property color base0A: "#909495"
        readonly property color base0B: "#c8be46"
        readonly property color base0C: "#615f5e"
        readonly property color base0D: "#737074"
        readonly property color base0E: "#737271"
        readonly property color base0F: "#736d21"
        readonly property color base10: "#353738"
        readonly property color base11: "#1a1b1c"
        readonly property color base12: "#fff68d"
        readonly property color base13: "#feed6c"
        readonly property color base14: "#fff27c"
        readonly property color base15: "#a2a2a5"
        readonly property color base16: "#909495"
        readonly property color base17: "#9a999d"
    }
}
