 This file is part of the KDE project.

Copyright (C) 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

import QtQuick 2.5
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents

import org.kde.plasma.private.sessions
import "../components"

PlasmaCore.ColorScope {

    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup

    Connections {
        target: authenticator
        onFailed: {
            root.notification = i18nd("plasma_lookandfeel_org.kde.lookandfeel","Unlocking failed");
        }
        onGraceLockedChanged: {
            if (!authenticator.graceLocked) {
                root.notification = "";
                root.clearPassword();
            }
        }
        onMessage: {
            root.notification = msg;
        }
        onError: {
            root.notification = err;
        }
    }

    SessionsModel {
        id: sessionsModel
        showNewSessionEntry: true
    }

    PlasmaCore.DataSource {
        id: keystateSource
        engine: "keystate"
        connectedSources: "Caps Lock"
    }

    Loader {
        id: changeSessionComponent
        active: false
        source: "ChangeSession.qml"
        visible: false
    }

    Item {
        id: lockScreenRoot

        x: parent.x
        y: parent.y
        width: parent.width
        height: parent.height

        Component.onCompleted: PropertyAnimation { id: launchAnimation; target: lockScreenRoot; property: "opacity"; from: 0; to: 1; duration: 1000 }

        states: [
            State {
                name: "onOtherSession"
                PropertyChanges { target: lockScreenRoot; y: lockScreenRoot.height }
                PropertyChanges { target: lockScreenRoot; opacity: 0 }
            }
        ]

        transitions:
            Transition {
                from: ""
                to: "onOtherSession"

                PropertyAnimation { id: stateChangeAnimation; properties: "y"; duration: 300; easing: Easing.InQuad}
                PropertyAnimation { properties: "opacity"; duration: 300}

                onRunningChanged: {
                    if (/* lockScreenRoot.state == "onOtherSession" && */ !running) {
                        mainStack.currentItem.switchSession()
                    }
                }
            }

        Clock {
            id: clock
            anchors.horizontalCenter: parent.horizontalCenter
            y: (mainBlock.userList.y + mainStack.y)/2 - height/2
            visible: y > 0
            Layout.alignment: Qt.AlignBaseline
        }

        ListModel {
            id: users

            Component.onCompleted: {
                users.append({name: kscreenlocker_userName,
                                realName: kscreenlocker_userName,
                                icon: kscreenlocker_userImage,

                })
            }
        }


        StackView {
            id: mainStack
            anchors {
                left: parent.left
                right: parent.right
            }
            height: lockScreenRoot.height
            focus: true //StackView is an implicit focus scope, so we need to give this focus so the item inside will have it

            initialItem: MainBlock {
                id: mainBlock

                showUserList: userList.y + mainStack.y > 0

                Stack.onStatusChanged: {
                    if (Stack.status == Stack.Activating) {
                        mainPasswordBox.remove(0, mainPasswordBox.length)
                        mainPasswordBox.focus = true
                    }
                }
                userListModel: users
                notificationMessage: {
                    var text = ""
                    if (keystateSource.data["Caps Lock"]["Locked"]) {
                        text += i18nd("plasma_lookandfeel_org.kde.lookandfeel","Caps Lock is on")
                        if (root.notification) {
                            text += " • "
                        }
                    }
                    text += root.notification
                    return text
                }

                onLoginRequest: {
                    root.notification = ""
                    authenticator.startAuthenticating(); authenticator.respond(password)
                }

                actionItems: [
                    ActionButton {
                        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Switch User")
                        iconSource: "system-switch-user"
                        onClicked: mainStack.push(switchSessionPage)
                        visible: (sessionsModel.count > 0 || sessionsModel.canStartNewSession) && sessionsModel.canSwitchUser
                    }
                ]

                Loader {
                    Layout.fillWidth: true
                    Layout.preferredHeight: item ? item.implicitHeight : 0
                    active: true // TODO configurable
                    source: "MediaControls.qml"
                }
            }
        }

        Loader {
            id: inputPanel
            state: "hidden"
            readonly property bool keyboardActive: item ? item.active : false
            anchors {
                left: parent.left
                right: parent.right
            }
            function showHide() {
                state = state == "hidden" ? "visible" : "hidden";
            }
            Component.onCompleted: inputPanel.source = "../components/VirtualKeyboard.qml"
            
            states: [
                State {
                    name: "visible"
                    PropertyChanges {
                        target: mainStack
                        y: Math.min(0, lockScreenRoot.height - inputPanel.height - mainBlock.visibleBoundary)
                    }
                    PropertyChanges {
                        target: inputPanel
                        y: lockScreenRoot.height - inputPanel.height
                        opacity: 1
                    }
                },
                State {
                    name: "hidden"
                    PropertyChanges {
                        target: mainStack
                        y: 0
                    }
                    PropertyChanges {
                        target: inputPanel
                        y: lockScreenRoot.height - lockScreenRoot.height/4
                        opacity: 0
                    }
                }
            ]
            transitions: [
                Transition {
                    from: "hidden"
                    to: "visible"
                    SequentialAnimation {
                        ScriptAction {
                            script: {
                                inputPanel.item.activated = true;
                                Qt.inputMethod.show();
                            }
                        }
                        ParallelAnimation {
                            NumberAnimation {
                                target: mainStack
                                property: "y"
                                duration: units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                target: inputPanel
                                property: "y"
                                duration: units.longDuration
                                easing.type: Easing.OutQuad
                            }
                            OpacityAnimator {
                                target: inputPanel
                                duration: units.longDuration
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                },
                Transition {
                    from: "visible"
                    to: "hidden"
                    SequentialAnimation {
                        ParallelAnimation {
                            NumberAnimation {
                                target: mainStack
                                property: "y"
                                duration: units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                target: inputPanel
                                property: "y"
                                duration: units.longDuration
                                easing.type: Easing.InQuad
                            }
                            OpacityAnimator {
                                target: inputPanel
                                duration: units.longDuration
                                easing.type: Easing.InQuad
                            }
                        }
                        ScriptAction {
                            script: {
                                Qt.inputMethod.hide();
                            }
                        }
                    }
                }
            ]
        }

        Component {
            id: switchSessionPage
            SessionManagementScreen {
                property var switchSession: finalSwitchSession

                Stack.onStatusChanged: {
                    if (Stack.status == Stack.Activating) {
                        focus = true
                    }
                }

                userListModel: sessionsModel

                function initSwitchSession() {
                    lockScreenRoot.state = 'onOtherSession'
                }

                function finalSwitchSession() {
                    mainStack.pop({immediate:true})
                    sessionsModel.switchUser(userListCurrentModelData.vtNumber)
                    lockScreenRoot.state = ''
                }

                Keys.onLeftPressed: userList.decrementCurrentIndex()
                Keys.onRightPressed: userList.incrementCurrentIndex()
                Keys.onEnterPressed: initSwitchSession()
                Keys.onReturnPressed: initSwitchSession()
                Keys.onEscapePressed: mainStack.pop()

                PlasmaComponents.Button {
                    Layout.fillWidth: true
                    text: userListCurrentModelData.vtNumber === -1 ? i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Start New Session") : i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Switch Session")
                    onClicked: initSwitchSession()
                }

                actionItems: [
                    ActionButton {
                        iconSource: "go-previous"
                        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel","Back")
                        onClicked: mainStack.pop()
                    }
                ]
            }
        }

        Loader {
            active: root.viewVisible
            source: "LockOsd.qml"
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }
        }

        RowLayout {
            id: footer
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                margins: units.smallSpacing
            }

            PlasmaComponents.ToolButton {
                text: i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "Button to show/hide virtual keyboard", "Virtual Keyboard")
                iconName: inputPanel.keyboardActive ? "input-keyboard-virtual-on" : "input-keyboard-virtual-off"
                onClicked: inputPanel.showHide()

                visible: inputPanel.status == Loader.Ready
            }

            KeyboardLayoutButton {
            }

            Item {
                Layout.fillWidth: true
            }

            Battery {}
        }
    }

    Component.onCompleted: {
        if (root.interfaceVersion < 1) {
            root.viewVisible = true;
        }
    }
}
