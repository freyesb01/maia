
import QtQuick 2.5

Image {
    id: root
    source: "../components/artwork/background.png"
    fillMode: Image.PreserveAspectCrop

    property int stage

    onStageChanged: {
        if (stage == 2) {
            introAnimation.running = true;
        } else if (stage == 5) {
            introAnimation.target = busyIndicator;
            introAnimation.from = 1;
            introAnimation.to = 0;
            introAnimation.running = true;
        }
    }

    Item {
        id: content
        anchors.fill: parent
        opacity: 0
        TextMetrics {
            id: units
            text: "M"
            property int gridUnit: boundingRect.height
            property int largeSpacing: units.gridUnit
            property int smallSpacing: Math.max(2, gridUnit/4)
        }

        Image {
            id: logo
            property real size: units.gridUnit * 8

            anchors.centerIn: parent

            source: "images/manjaro.svgz"

            sourceSize.width: size
            sourceSize.height: size
        }

        Image {
            id: busyIndicator
            y: parent.height - (parent.height - logo.y) / 2 - height/2
            anchors.horizontalCenter: parent.horizontalCenter
            source: "images/busywidget.svgz"
            sourceSize.height: units.gridUnit * 2
            sourceSize.width: units.gridUnit * 2
            RotationAnimator on rotation {
                id: rotationAnimator
                from: 0
                to: 360
                duration: 1500
                loops: Animation.Infinite
            }
        }
        Row {
            spacing: units.smallSpacing*2
            anchors {
                bottom: parent.bottom
                right: parent.right
                margins: units.gridUnit
            }
            Text {
                color: "#eff0f1"
                renderType: Text.NativeRendering
                anchors.verticalCenter: parent.verticalCenter
                text: i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "This is the first text the user sees while starting in the splash screen, should be translated as something short, is a form that can be seen on a product. Plasma is the project name so shouldn't be translated.", "Plasma made by KDE")
            }
            Image {
                source: "images/kde.svgz"
                sourceSize.height: units.gridUnit * 2
                sourceSize.width: units.gridUnit * 2
            }
        }
    }

    OpacityAnimator {
        id: introAnimation
        running: false
        target: content
        from: 0
        to: 1
        duration: 1000
        easing.type: Easing.InOutQuad
    }
}
