
import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1 as Controls

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents

import org.kde.plasma.private.sessions

import "../components"

PlasmaCore.ColorScope {
    id: root
    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup

    signal dismissed
    signal ungrab

    height:screenGeometry.height
    width: screenGeometry.width

    Rectangle {
        anchors.fill: parent
        color: PlasmaCore.ColorScope.backgroundColor
        opacity: 0.5
    }

    SessionsModel {
        id: sessionsModel
        showNewSessionEntry: true

        onStartedNewSession: root.dismissed()
        onSwitchedUser: root.dismissed()

        onAboutToLockScreen: root.ungrab()
    }

    Controls.Action {
        onTriggered: root.dismissed()
        shortcut: "Escape"
    }

    Clock {
        anchors.bottom: parent.verticalCenter
        anchors.bottomMargin: units.gridUnit * 13
        anchors.horizontalCenter: parent.horizontalCenter
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.dismissed()
    }

    SessionManagementScreen {
        id: block
        anchors.fill: parent

        userListModel: sessionsModel

        RowLayout {
            PlasmaComponents.Button {
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel","Cancel")
                onClicked: root.dismissed()
            }
            PlasmaComponents.Button {
                id: commitButton
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel","Switch")
                visible: sessionsModel.count > 0
                onClicked: {
                    sessionsModel.switchUser(block.userListCurrentModelData.vtNumber, sessionsModel.shouldLock)
                }

                Controls.Action {
                    onTriggered: commitButton.clicked()
                    shortcut: "Return"
                }
                Controls.Action {
                    onTriggered: commitButton.clicked()
                    shortcut: "Enter" // on numpad
                }
            }
        }
    }
}
