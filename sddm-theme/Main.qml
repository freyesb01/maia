
import QtQuick 2.2

import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras

import "components"

PlasmaCore.ColorScope {
    id: root
    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup

    width: 1600
    height: 900

    property string notificationMessage

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    PlasmaCore.DataSource {
        id: keystateSource
        engine: "keystate"
        connectedSources: "Caps Lock"
    }

    Repeater {
        model: screenModel

        Background {
            x: geometry.x; y: geometry.y; width: geometry.width; height: geometry.height
            sceneBackgroundType: 
            {
                if ( config.background == "components/artwork/background.png"
                    && config.type != "color" ) 
                    return "image"
                return config.type
            }
            sceneBackgroundColor: config.color
            sceneBackgroundImage: config.background
        }
    }

    Clock {
        visible: y > 0
        y: (userListComponent.userList.y + mainStack.y)/2 - height/2
        anchors.horizontalCenter: parent.horizontalCenter
    }


    StackView {
        id: mainStack
        anchors {
            left: parent.left
            right: parent.right
        }
        height: root.height

        focus: true //StackView is an implicit focus scope, so we need to give this focus so the item inside will have it

        Timer {
            running: true
            repeat: false
            interval: 200
            onTriggered: mainStack.forceActiveFocus()
        }

        initialItem: Login {
            id: userListComponent
            userListModel: userModel
            userListCurrentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
            lastUserName: userModel.lastUser
            showUserList: {
                if ( !userListModel.hasOwnProperty("count")
                || !userListModel.hasOwnProperty("disableAvatarsThreshold"))
                    return (userList.y + mainStack.y) > 0

                if ( userListModel.count == 0 ) return false

                return userListModel.count <= userListModel.disableAvatarsThreshold && (userList.y + mainStack.y) > 0
            }

            notificationMessage: {
                var text = ""
                if (keystateSource.data["Caps Lock"]["Locked"]) {
                    text += i18nd("plasma_lookandfeel_org.kde.lookandfeel","Caps Lock is on")
                    if (root.notificationMessage) {
                        text += " • "
                    }
                }
                text += root.notificationMessage
                return text
            }

            actionItems: [
                ActionButton {
                    iconSource: "system-suspend"
                    text: i18nd("plasma_lookandfeel_org.kde.lookandfeel","Suspend")
                    onClicked: sddm.suspend()
                    enabled: sddm.canSuspend
                    visible: !inputPanel.keyboardActive
                },
                ActionButton {
                    iconSource: "system-reboot"
                    text: i18nd("plasma_lookandfeel_org.kde.lookandfeel","Restart")
                    onClicked: sddm.reboot()
                    enabled: sddm.canReboot
                    visible: !inputPanel.keyboardActive
                },
                ActionButton {
                    iconSource: "system-shutdown"
                    text: i18nd("plasma_lookandfeel_org.kde.lookandfeel","Shutdown")
                    onClicked: sddm.powerOff()
                    enabled: sddm.canPowerOff
                    visible: !inputPanel.keyboardActive
                },
                ActionButton {
                    iconSource: "system-search"
                    text: i18nd("plasma_lookandfeel_org.kde.lookandfeel","Different User")
                    onClicked: mainStack.push(userPromptComponent)
                    enabled: true
                    visible: !userListComponent.showUsernamePrompt && !inputPanel.keyboardActive
                }
            ]

            onLoginRequest: {
                root.notificationMessage = ""
                sddm.login(username, password, sessionButton.currentIndex)
            }
        }

        Behavior on opacity {
            OpacityAnimator {
                duration: units.longDuration
            }
        }
    }

    Loader {
        id: inputPanel
        state: "hidden"
        property bool keyboardActive: item ? item.active : false
        onKeyboardActiveChanged: {
            if (keyboardActive) {
                state = "visible"
            } else {
                state = "hidden";
            }
        }
        source: "components/VirtualKeyboard.qml"
        anchors {
            left: parent.left
            right: parent.right
        }

        function showHide() {
            state = state == "hidden" ? "visible" : "hidden";
        }

        states: [
            State {
                name: "visible"
                PropertyChanges {
                    target: mainStack
                    y: Math.min(0, root.height - inputPanel.height - userListComponent.visibleBoundary)
                }
                PropertyChanges {
                    target: inputPanel
                    y: root.height - inputPanel.height
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
                    y: root.height - root.height/4
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
        id: userPromptComponent
        Login {
            showUsernamePrompt: true
            notificationMessage: root.notificationMessage

            userListModel: QtObject {
                property string name: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Login as different user")
                property string iconSource: ""
            }

            onLoginRequest: {
                root.notificationMessage = ""
                sddm.login(username, password, sessionButton.currentIndex)
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

    RowLayout {
        id: footer
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: units.smallSpacing
        }

        Behavior on opacity {
            OpacityAnimator {
                duration: units.longDuration
            }
        }

        PlasmaComponents.ToolButton {
            text: i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "Button to show/hide virtual keyboard", "Virtual Keyboard")
            iconName: inputPanel.keyboardActive ? "input-keyboard-virtual-on" : "input-keyboard-virtual-off"
            onClicked: inputPanel.showHide()
            visible: inputPanel.status == Loader.Ready
        }

        KeyboardButton {
        }

        SessionButton {
            id: sessionButton
        }

        Item {
            Layout.fillWidth: true
        }

        Battery { }
    }

    Connections {
        target: sddm
        onLoginFailed: {
            notificationMessage = i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Login Failed")
        }
        onLoginSucceeded: {
            mainStack.opacity = 0
            footer.opacity = 0
        }
    }

    onNotificationMessageChanged: {
        if (notificationMessage) {
            notificationResetTimer.start();
        }
    }

    Timer {
        id: notificationResetTimer
        interval: 3000
        onTriggered: notificationMessage = ""
    }

}
