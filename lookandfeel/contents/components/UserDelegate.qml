
import QtQuick 2.4

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents

Item {
    id: wrapper

    property bool isCurrent: true

    readonly property var m: model
    property string name
    property string userName
    property string avatarPath
    property string iconSource
    signal clicked()

    property real faceSize: Math.min(width, height - usernameDelegate.height - units.largeSpacing)

    opacity: isCurrent ? 1.0 : 0.5

    Behavior on opacity {
        OpacityAnimator {
            duration: units.longDuration
        }
    }

    Item {
        id: imageSource
        width: faceSize
        height: faceSize

        Image {
            id: face
            source: wrapper.avatarPath
            fillMode: Image.PreserveAspectCrop
            anchors.fill: parent
            mipmap: true
            smooth: true
        }

        PlasmaCore.IconItem {
            id: faceIcon
            source: iconSource
            visible: (face.status == Image.Error || face.status == Image.Null)
            anchors.fill: parent
            anchors.margins: units.gridUnit * 0.5 // because mockup says so...
            colorGroup: PlasmaCore.ColorScope.colorGroup
        }
    }

    ShaderEffect {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        width: imageSource.width
        height: imageSource.height

        supportsAtlasTextures: true

        property var source: ShaderEffectSource {
            sourceItem: imageSource
            hideSource: true
            live: false
        }

        property var colorBorder: PlasmaCore.ColorScope.textColor


        fragmentShader: "
                        varying highp vec2 qt_TexCoord0;
                        uniform highp float qt_Opacity;
                        uniform lowp sampler2D source;

                        uniform vec4 colorBorder;
                        float blend = 0.01;
                        float innerRadius = 0.47;
                        float outerRadius = innerRadius + 0.02;
                        vec4 colorEmpty = vec4(0.0, 0.0, 0.0, 0.0);

                        void main() {
                            vec4 colorSource = texture2D(source, qt_TexCoord0.st);

                            vec2 m = qt_TexCoord0 - vec2(0.5, 0.5);
                            float dist = sqrt(m.x * m.x + m.y * m.y);

                            if (dist < innerRadius)
                                gl_FragColor = colorSource;
                            else if (dist < innerRadius + blend)
                                gl_FragColor = mix(colorSource, colorBorder, ((dist - innerRadius) / blend));
                            else if (dist < outerRadius)
                                gl_FragColor = colorBorder;
                            else if (dist < outerRadius + blend)
                                gl_FragColor = mix(colorBorder, colorEmpty, ((dist - outerRadius) / blend));
                            else
                                gl_FragColor = colorEmpty ;

                            gl_FragColor = gl_FragColor * qt_Opacity;
                    }
        "
    }



    PlasmaComponents.Label {
        id: usernameDelegate
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        height: implicitHeight // work around stupid bug in Plasma Components that sets the height
        text: wrapper.name
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        font.underline: wrapper.activeFocus
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onClicked: wrapper.clicked();
    }

    Accessible.name: name
    Accessible.role: Accessible.Button
    function accessiblePressAction() { wrapper.clicked() }
}
