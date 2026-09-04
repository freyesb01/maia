
import QtQuick 2.2

import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents

Item {
    id: root

    property alias notificationMessage: notificationsLabel.text

    property alias actionItems: actionItemsLayout.children

    property alias userListModel: userListView.model

    property alias userListCurrentIndex: userListView.currentIndex
    property var userListCurrentModelData: userListView.currentItem === null ? [] : userListView.currentItem.m
    property bool showUserList: true

    property alias userList: userListView

    default property alias _children: innerLayout.children


    UserList {
        id: userListView
        visible: showUserList && y > 0
        anchors {
            bottom: parent.verticalCenter
            left: parent.left
            right: parent.right
        }
    }

    ColumnLayout {
        id: prompts
        anchors.top: parent.verticalCenter
        anchors.topMargin: units.gridUnit * 0.5
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        PlasmaComponents.Label {
            id: notificationsLabel
            Layout.maximumWidth: units.gridUnit * 16
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.italic: true
        }
        ColumnLayout {
            Layout.minimumHeight: implicitHeight
            Layout.maximumHeight: units.gridUnit * 10
            Layout.maximumWidth: units.gridUnit * 16
            Layout.alignment: Qt.AlignHCenter
            ColumnLayout {
                id: innerLayout
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }
            Item {
                Layout.fillHeight: true
            }
        }
        Row { //deliberately not rowlayout as I'm not trying to resize child items
            id: actionItemsLayout
            spacing: units.smallSpacing
            Layout.alignment: Qt.AlignHCenter
        }
        Item {
            Layout.fillHeight: true
        }
    }
}
