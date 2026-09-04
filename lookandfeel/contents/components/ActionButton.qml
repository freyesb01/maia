
import QtQuick 2.2
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents

Item {
    id: root
    property alias text: label.text
    property alias iconSource: icon.source
    property alias containsMouse: mouseArea.containsMouse
    signal clicked

    activeFocusOnTab: true

    property int iconSize: units.gridUnit * 3

    implicitWidth: Math.max(iconSize + units.largeSpacing * 2, label.contentWidth)
    implicitHeight: iconSize + units.smallSpacing + label.implicitHeight

    PlasmaCore.IconItem {
        id: icon
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        width: iconSize
        height: iconSize

        colorGroup: PlasmaCore.ColorScope.colorGroup
        active: mouseArea.containsMouse || root.activeFocus
    }
    PlasmaComponents.Label {
        id: label
        anchors {
            top: icon.bottom
            topMargin: units.smallSpacing
            left: parent.left
            right: parent.right
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
    }

    MouseArea {
        id: mouseArea
        hoverEnabled: true
        onClicked: root.clicked()
        anchors.fill: parent
    }

    Keys.onEnterPressed: clicked()
    Keys.onReturnPressed: clicked()
    Keys.onSpacePressed: clicked()

    Accessible.onPressAction: clicked()
    Accessible.role: Accessible.Button
    Accessible.name: label.text
}
