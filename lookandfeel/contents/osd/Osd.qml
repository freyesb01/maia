
import QtQuick 2.0
import QtQuick.Window 2.2
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtra

PlasmaCore.Dialog {
    id: root
    location: PlasmaCore.Types.Floating
    type: PlasmaCore.Dialog.OnScreenDisplay
    outputOnly: true

    property int timeout: 1800
    property var osdValue
    property string icon
    property bool showingProgress: false

    property bool animateOpacity: false

    Behavior on opacity {
        SequentialAnimation {
            PauseAnimation { duration: 100 }
            NumberAnimation {
                duration: root.timeout
                easing.type: Easing.InQuad
            }
        }
        enabled: root.animateOpacity
    }

    mainItem: OsdItem {
        rootItem: root
    }
}
