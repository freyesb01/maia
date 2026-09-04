
import QtQuick 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtra
import QtQuick.Window 2.2

Item {
    property QtObject rootItem
    height: Math.min(units.gridUnit * 15, Screen.desktopAvailableHeight / 5)
    width: height


    PlasmaCore.IconItem {
        id: icon

        height: parent.height - Math.max(progressBar.height, label.height)
                              - ((units.smallSpacing/2) * 3) //it's an svg
        width: parent.width

        source: rootItem.icon
    }

    PlasmaComponents.ProgressBar {
        id: progressBar

        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: Math.floor(units.smallSpacing / 2)
        }

        visible: rootItem.showingProgress
        minimumValue: 0
        maximumValue: 100

        value: Number(rootItem.osdValue)
    }
    PlasmaExtra.Heading {
        id: label
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: Math.floor(units.smallSpacing / 2)
        }

        visible: !rootItem.showingProgress
        text: rootItem.showingProgress ? "" : (rootItem.osdValue ? rootItem.osdValue : "")
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        maximumLineCount: 2
        elide: Text.ElideLeft
        minimumPointSize: theme.defaultFont.pointSize
        fontSizeMode: Text.HorizontalFit
    }
}
