
import QtQuick 2.2
import QtQuick.Layouts 1.2

import org.kde.plasma.core as PlasmaCore

import "../components"

ActionButton {
    property var action
    onClicked: action()
    iconSize: units.iconSizes.huge
    opacity: activeFocus || containsMouse ? 1 : 0.5
    Behavior on opacity {
        OpacityAnimator {
            duration: units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
    Keys.onPressed: countDownTimer.running = false
}
