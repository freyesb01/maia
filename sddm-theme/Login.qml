import "components"

import QtQuick 2.0
import QtQuick.Layouts 1.2

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents

SessionManagementScreen {

    property bool showUsernamePrompt: !showUserList

    property string lastUserName

    property int visibleBoundary: mapFromItem(loginButton, 0, 0).y
    onHeightChanged: visibleBoundary = mapFromItem(loginButton, 0, 0).y + loginButton.height + units.smallSpacing

    signal loginRequest(string username, string password)

    onShowUsernamePromptChanged: {
        if (!showUsernamePrompt) {
            lastUserName = ""
        }
    }

    function startLogin() {
        var username = showUsernamePrompt ? userNameInput.text : userList.selectedUser
        var password = passwordBox.text

        loginButton.forceActiveFocus();
        loginRequest(username, password);
    }

    PlasmaComponents.TextField {
        id: userNameInput
        Layout.fillWidth: true

        text: lastUserName
        visible: showUsernamePrompt
        focus: showUsernamePrompt && !lastUserName //if there's a username prompt it gets focus first, otherwise password does
        placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Username")
    }

    PlasmaComponents.TextField {
        id: passwordBox
        Layout.fillWidth: true

        placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Password")
        focus: !showUsernamePrompt || lastUserName
        echoMode: TextInput.Password
        revealPasswordButtonShown: true

        onAccepted: startLogin()

        Keys.onEscapePressed: {
            mainStack.currentItem.forceActiveFocus();
        }

        Keys.onPressed: {
            if (event.key == Qt.Key_Left && !text) {
                userList.decrementCurrentIndex();
                event.accepted = true
            }
            if (event.key == Qt.Key_Right && !text) {
                userList.incrementCurrentIndex();
                event.accepted = true
            }
        }

        Connections {
            target: sddm
            onLoginFailed: {
                passwordBox.selectAll()
                passwordBox.forceActiveFocus()
            }
        }
    }
    PlasmaComponents.Button {
        id: loginButton
        Layout.fillWidth: true

        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Login")
        onClicked: startLogin();
    }

}
