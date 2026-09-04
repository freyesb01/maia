import QtQuick 2.0


ListModel {
    property int primary: 0
    

    Component.onCompleted: {
        append({
            name: "Screen 1",
            geometry: {x: 0, y: 0, width: 1600, height: 900},
        });

        append({
            name: "Screen 2",
            geometry: {x: 1980, y: 0, width: 1600, height: 900},
        });
    }

    function geometry() {
        return Qt.rect(800, 0, 800, 400);
    }
}
