import QtQuick 2.12
import QtQuick.Controls 2.12

Page {
    id: root
    //width: 600
    //height: 400

    property alias txtEditor: txtEditor

    title: qsTr("Home")

    ScrollView {
        id: scrollView
        clip: true
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.rightMargin: 5
        anchors.leftMargin: 5
        anchors.topMargin: 5
        anchors.bottomMargin: 5

        TextEdit {
            id: txtEditor
            text: qsTr("You are on the home page.")
            anchors.centerIn: parent
        }
    }
}
