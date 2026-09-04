
import QtQuick 2.0
import QtQuick.Layouts 1.1

import org.kde.plasma.core
import org.kde.plasma.components

ColumnLayout {
    Label {
        text: Qt.formatTime(timeSource.data["Local"]["DateTime"])
        font.pointSize: 32 //Mockup says this, I'm not sure what to do?
        Layout.alignment: Qt.AlignHCenter
    }
    Label {
        text: Qt.formatDate(timeSource.data["Local"]["DateTime"], Qt.DefaultLocaleLongDate)
        font.pointSize: 18
        Layout.alignment: Qt.AlignHCenter
    }
    DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 1000
    }
}
