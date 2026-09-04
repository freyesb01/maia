
import QtQuick 2.2

import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents

import "../components"

SessionManagementScreen {

    property Item mainPasswordBox: passwordBox

    property int visibleBoundary: mapFromItem(loginButton, 0, 0).y
    onHeightChanged: visibleBoundary = mapFromItem(loginButton, 0, 0).y + loginButton.height + units.smallSpacing
    signal loginRequest(string password)

    function startLogin() {
        var password = passwordBox.text

        loginButton.forceActiveFocus();
        loginRequest(password);
    }

    PlasmaComponents.TextField {
        id: passwordBox
        Layout.fillWidth: true

        placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Password")
        focus: true
        echoMode: TextInput.Password
        inputMethodHints: Qt.ImhHiddenText | Qt.ImhSensitiveData | Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
        enabled: !authenticator.graceLocked
        revealPasswordButtonShown: true

        onAccepted: startLogin()

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
            target: root
            onClearPassword: {
                passwordBox.forceActiveFocus()
                passwordBox.selectAll()
            }
        }
    }

    PlasmaComponents.Button {
        id: loginButton
        Layout.fillWidth: true

        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Unlock")
        onClicked: startLogin()
    }
}
