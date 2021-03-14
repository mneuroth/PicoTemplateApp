import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.15

Page {
    id: root
    anchors.fill: parent

    title: qsTr("Settings")

    property alias btnOk: btnOk
    property alias btnCancel: btnCancel
    property alias btnRestoreDefaultSettings: btnRestoreDefaultSettings
    property alias chbUseToolBar: chbUseToolBar
    property alias chbOption1: chbOption1
    property alias chbOption2: chbOption2

    ScrollView {
        id: scrollView

        anchors.fill: parent
        anchors.margins: 10

        //contentWidth: lblSupportInfo.contentWidth // btnSupportLevel1.width //availableWidth
        contentHeight: layout.implicitHeight + 50
        clip: true

        ScrollBar.horizontal.policy: ScrollBar.AsNeeded
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        ColumnLayout {
            id: layout

            CheckBox {
                id: chbUseToolBar
                enabled: true
                text: qsTr("Show toolbar")
            }

            CheckBox {
                id: chbOption1
                enabled: true
                text: qsTr("option 1")
            }

            CheckBox {
                id: chbOption2
                enabled: true
                text: qsTr("option 2")
            }

            Row {
                spacing: 10

                anchors.top: chbOption2.bottom
                anchors.topMargin: 10

                Button {
                    id: btnOk
                    text: qsTr("Accept")
                }

                Button {
                    id: btnCancel
                    text: qsTr("Cancel")
                }

                Button {
                    id: btnRestoreDefaultSettings
                    text: qsTr("Default Values")
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:2;anchors_x:156}D{i:1;anchors_height:200;anchors_width:200;anchors_x:0;anchors_y:0}
}
##^##*/

