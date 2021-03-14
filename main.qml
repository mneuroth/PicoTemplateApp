import QtQuick 2.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.12
import Qt.labs.settings 1.0

ApplicationWindow {
    id: window
    width: 800
    height: 600
    visible: true
    title: qsTr("Pico App")

    property string currentFileName: qsTr("unknown.txt")
    property string currentDecodedFileName: ""
    property string currentDirectory: "."

    property int iconSize: 40
    property int defaultIconSize: 40

    function setFileName(fileUri, decodedFileUri) {
        currentFileName = fileUri
        currentDecodedFileName = decodedFileUri
    }

    function addToOutput(txt) {
        homePage.txtEditor.text += txt + "\n"
    }

    function addErrorMessage(msg) {
        addToOutput(msg)
    }

    function focusToEditor() {
        homePage.txtEditor.forceActiveFocus()
    }

    function processOpenFileCallback(fileName) {
        var content = applicationData.readFileContent(fileName)
        setFileName(fileName, null)
        homePage.txtEditor.text = content
    }

    function processSaveFileCallback(fileName) {
        var content = homePage.txtEditor.text
        setFileName(fileName, null)
        doSaveFile(currentFileName, content, true)
    }

    function doSaveFile(fileName, text, bForceSyncWrite) {
        if( !bForceSyncWrite && applicationData.isWASM && !applicationData.isUseLocalFileDialog )
        {
            applicationData.saveFileContentAsync(text, applicationData.getOnlyFileName(fileName))
        }
        else
        {
            var ok = applicationData.writeFileContent(fileName, text)
            if( !ok )
            {
                var msg= localiseText(qsTr("ERROR: Can not save file ")) + fileName
                addErrorMessage(msg)
            }
        }
    }

    function triggerSaveAsFile() {
        if( !applicationData.isMobileUI )
        {
            fileDialog.openMode = false
            fileDialog.folder = "."
            fileDialog.nameFilters = ["*"]
            fileDialog.open()
        }
        else
        {
            stackView.pop()
            mobileFileDialog.pathsSDCard = applicationData.getSDCardPaths()
            mobileFileDialog.isStorageSupported = applicationData.isAndroid
            mobileFileDialog.isMobilePlatform = applicationData.isAndroid
            mobileFileDialog.isAdminModus = !applicationData.isAndroid
            mobileFileDialog.homePath = applicationData.homePath
            mobileFileDialog.setDirectory(currentDirectory)
            mobileFileDialog.setSaveAsModus(false)
            stackView.push(mobileFileDialog)
            mobileFileDialog.forceActiveFocus()
        }
    }

    function triggerOpenFile() {
        if( applicationData.isWASM && !applicationData.isUseLocalFileDialog )
        {
            applicationData.getOpenFileContentAsync("*.txt")
        }
        else if( !applicationData.isMobileUI )
        {
            fileDialog.openMode = true
            fileDialog.folder = "."
            fileDialog.nameFilters = ["*"]
            fileDialog.open()
        }
        else
        {
            stackView.pop()
            mobileFileDialog.pathsSDCard = applicationData.getSDCardPaths() // or: ["c:\\tmp","c:\\"]
            mobileFileDialog.isStorageSupported = applicationData.isAndroid
            mobileFileDialog.isMobilePlatform = applicationData.isAndroid
            mobileFileDialog.isAdminModus = !applicationData.isAndroid
            mobileFileDialog.homePath = applicationData.homePath
            mobileFileDialog.setDirectory(currentDirectory)
            mobileFileDialog.setOpenModus()
            stackView.push(mobileFileDialog)
            mobileFileDialog.forceActiveFocus()
        }
    }

    function showSettingsDialog() {
        settingsDialog.chbUseToolBar.checked = settings.useToolBar
        stackView.push(settingsDialog)
    }

    function isDialogOpen() {
        return stackView.currentItem === aboutDialog ||
               stackView.currentItem === mobileFileDialog ||
               stackView.currentItem === settingsDialog
    }

    header: ToolBar {
        contentHeight: toolButton.implicitHeight

        ToolButton {
            id: toolButton
            //text: stackView.depth > 1 ? "\u25C0" : "\u2630"
            icon.source: stackView.depth > 1 ? "back" : "menu_bars"
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            anchors.left: parent.left
            onClicked: {
                if (stackView.depth > 1) {
                    stackView.pop()
                } else {
                    drawer.open()
                }
            }
        }

        Label {
            text: stackView.currentItem.title
            anchors.centerIn: parent
        }

        ToolButton {
            id: menuButton
            //text: "\u22EE"
            icon.source: "menu.svg"
            font.pixelSize: Qt.application.font.pixelSize * 2.0
            anchors.right: parent.right
            onClicked: menu.open()

            Menu {
                id: menu
                y: menuButton.height

                MenuItem {
                    text: qsTr("Open")
                    //icon.source: "open.svg"
                    enabled: !isDialogOpen()
                    onTriggered: {
                        triggerOpenFile()
                    }
                }
                MenuItem {
                    text: qsTr("Save")
                    //icon.source: "save.svg"
                    enabled: !isDialogOpen()
                    onTriggered: {
                        doSaveFile(currentFileName, homePage.txtEditor.text)
                    }
                }
                MenuItem {
                    text: qsTr("Save as")
                    //icon.source: "saveas.svg"
                    enabled: !isDialogOpen()
                    onTriggered: {
                        triggerSaveAsFile()
                    }
                }
                MenuItem {
                    text: qsTr("Delete")
                    //icon.source: "delete.svg"
                    enabled: !isDialogOpen()
                    onTriggered: {
                        stackView.pop()
                        mobileFileDialog.pathsSDCard = applicationData.getSDCardPaths()
                        mobileFileDialog.isStorageSupported = applicationData.isAndroid
                        mobileFileDialog.isMobilePlatform = applicationData.isAndroid
                        mobileFileDialog.isAdminModus = !applicationData.isAndroid
                        mobileFileDialog.homePath = applicationData.homePath
                        mobileFileDialog.setDirectory(currentDirectory)
                        mobileFileDialog.setDeleteModus()
                        stackView.push(mobileFileDialog)
                        mobileFileDialog.forceActiveFocus()
                    }
                }                
                MenuSeparator {}
                MenuItem {
                    text: qsTr("Settings")
                    enabled: !isDialogOpen()
                    onTriggered: {
                        showSettingsDialog()
                    }
                }
                MenuSeparator {}
                MenuItem {
                    text: qsTr("About")
                    enabled: !isDialogOpen()
                    onTriggered: {
                        stackView.push(aboutDialog)
                    }
                }
                MenuSeparator {}
                MenuItem {
                    text: qsTr("Exit")
                    onTriggered: {
                        Qt.quit()
                    }
                }
            }
        }
    }

    ToolBar {
        id: toolBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        visible: settings.useToolBar
        height: settings.useToolBar ? flow.implicitHeight/*implicitHeight*/ : 0

        onHeightChanged: {
            if( toolBar.height>2*iconSize+flow.spacing ) {
                iconSize -= 2
            } else if ( toolBar.height<defaultIconSize ) {
                if( iconSize<defaultIconSize ) {
                    iconSize += 1
                }
            }
        }

        Flow {
            id: flow
            anchors.fill: parent
            spacing: 5

            ToolButton {
                id: toolButtonOpen
                icon.source: "open-folder-with-document.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Open"
                onClicked: {
                    triggerOpenFile()
                }
            }
            ToolButton {
                id: toolButtonSave
                icon.source: "floppy-disk.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Save"
                onClicked: {
                    triggerSaveAsFile()
                }
            }
            ToolButton {
                id: toolButtonUndo
                icon.source: "back-arrow.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Undo"
                onClicked: {
                }
            }
            ToolButton {
                id: toolButtonRedo
                icon.source: "redo-arrow.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Redo"
                onClicked: {
                }
            }
            ToolButton {
                id: toolButtonSearch
                icon.source: "search.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Search"
                onClicked: {
                }
            }
            ToolButton {
                id: toolButtonReplace
                icon.source: "replace.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Replace"
                onClicked: {
                }
            }
            ToolButton {
                id: toolButtonPrevious
                icon.source: "left-arrow.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Previous"
                onClicked: {
                }
            }
            ToolButton {
                id: toolButtonNext
                icon.source: "right-arrow.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Next"
                onClicked: {
                }
            }
            ToolButton {
                id: toolButtonShare
                icon.source: "share.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Share"
                onClicked: {
                    var s = homePage.txtEditor.text
                    applicationData.shareSimpleText(s);
                }
            }
            ToolButton {
                id: toolButtonSettings
                icon.source: "settings.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Settings"
                onClicked: {
                    showSettingsDialog()
                }
            }
            ToolButton {
                id: toolButtonClose
                icon.source: "close.svg"
                enabled: !isDialogOpen()
                height: iconSize
                width: height
                //enabled: (stackView.currentItem === homePage) && !isDialogOpen()
                //text: "Close"
                onClicked: {
                }
            }
        }
    }

    Drawer {
        id: drawer
        width: window.width * 0.66
        height: window.height

        Column {
            anchors.fill: parent

            ItemDelegate {
                text: qsTr("Page 1")
                width: parent.width
                onClicked: {
                    stackView.push("Page1Form.ui.qml")
                    drawer.close()
                }
            }
            ItemDelegate {
                text: qsTr("Page 2")
                width: parent.width
                onClicked: {
                    stackView.push("Page2Form.ui.qml")
                    drawer.close()
                }
            }
        }
    }

    StackView {
        id: stackView
        initialItem: homePage
        //anchors.fill: parent
        anchors.top: toolBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
    }

    HomeForm {
        id: homePage
    }

    SettingsDialog {
        id: settingsDialog
        visible: false
    }

    AboutDialog {
        id: aboutDialog
        visible: false
    }

    MobileFileDialog {
        id: mobileFileDialog

        visible: false
    }

    FileDialog {
        id: fileDialog
        objectName: "fileDialog"
        visible: false
        modality: Qt.ApplicationModal
        //fileMode: openMode ? FileDialog.OpenFile : FileDialog.SaveFile
        title: openMode ? qsTr("Choose a file") : qsTr("Save as")
        folder: "."

        property bool openMode: true

        selectExisting: openMode ? true : false
        selectMultiple: false
        selectFolder: false
    }

    Settings {
        id: settings

        property bool useToolBar: true
    }

    Connections {
        target: fileDialog

        onAccepted: {
            if( fileDialog.openMode ) {
                processOpenFileCallback(fileDialog.fileUrl)
            }
            else {
                processSaveFileCallback(fileDialog.fileUrl)
            }
            fileDialog.close()
            focusToEditor()
        }
        onRejected: {
            fileDialog.close()
            focusToEditor()
        }
    }

    Connections {
        target: mobileFileDialog

        //onRejected: stackView.pop()       // for Qt 5.12.xx
        function onRejected() {
            stackView.pop()
            focusToEditor()
        }
        function onAccepted() {
            currentDirectory = mobileFileDialog.lblDirectoryName.text
            stackView.pop()
            focusToEditor()
        }

        function onSaveSelectedFile(fileName) {
            processSaveFileCallback(fileName)
        }
        function onOpenSelectedFile(fileName) {
            processOpenFileCallback(fileName)
        }
        function onDeleteSelectedFile(fileName) {
            var ok = applicationData.deleteFile(fileName)
            if( !ok ) {
                var msg= localiseText(qsTr("ERROR: Can not delete file ")) + fileName
                addErrorMessage(msg)
            }
        }

        function onStorageOpenFile() {
            console.log("storage open")
            addToOutput("storage open")
            storageAccess.openFile()
        }
        function onStorageCreateFile(fileNane) {
            console.log("storage create file "+fileNane)
            addToOutput("storage create file "+fileNane)
            setFileName(fileName, null)
            storageAccess.createFile(fileNane)
        }
    }

    Connections {
        target: aboutDialog

        function onClose() {
            stackView.pop()
        }
    }

    Connections {
        target: settingsDialog

        function onAccepted() {
            // TODO: update settings
            settings.useToolBar = settingsDialog.chbUseToolBar.checked

            stackView.pop()
        }
        function onRejected() {
            stackView.pop()
        }
        function onRestoreDefaultSettings() {
            // TODO: restore default settings
        }
    }

    Connections {
        target: applicationData

        // used for WASM platform:
        onReceiveOpenFileContent: {
            setFileName(fileName, null)
            homePage.txtEditor.text = fileContent
        }
        /*
        function receiveOpenFileContent(fileName, fileContent) {
            setFileName(fileName, null)
            homePage.txtEditor.text = fileContent
        }
        */        
        onSendErrorText: {
            homePage.txtEditor.text += "\n" + msg
        }
    }

    Connections {
        target: storageAccess

        function onOpenFileContentReceived(fileUri, decodedFileUri, fileContent) {
            console.log("onOpenFileContentReceived")
            addToOutput("onOpenFileContentReceived")
            homePage.txtEditor.text = fileContent
            setFileName(fileUri, decodedFileUri)
            stackView.pop()
        }
        function onOpenFileCanceled() {
            console.log("onOpenFileCanceled")
            addToOutput("onOpenFileCanceled")
            stackView.pop()
        }
        function onOpenFileError(message) {
            homePage.txtEditor.text = message
            stackView.pop()
        }
        function onCreateFileReceived(fileUri, decodedFileUri) {
            console.log("create file received "+fileUri+" decoded="+decodedFileUri)
            addToOutput("create file received "+fileUri+" decoded="+decodedFileUri)
            setFileName(fileUri, decodedFileUri)
        }
    }
}
