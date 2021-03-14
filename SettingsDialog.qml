import QtQuick 2.0
import QtQuick.Controls 2.1

SettingsDialogForm {

    signal rejected()
    signal accepted()

    signal restoreDefaultSettings()

    btnCancel {
        onClicked: rejected()
    }

    btnOk {
        onClicked: accepted()
    }

    btnRestoreDefaultSettings {
        onClicked: restoreDefaultSettings()
    }
}
