import QtQuick 2.0
import QtQuick.Controls 2.1

AboutDialogForm {

    signal close()

    lblAppInfos {
        text: applicationData !== null ? applicationData.getAppInfos() : "?"
    }

    lblIconInfos {
        onLinkActivated: Qt.openUrlExternally(link)
    }

    lblAppName {
        onLinkActivated: Qt.openUrlExternally(link)
    }

    lblGithubPage {
        onLinkActivated: Qt.openUrlExternally(link)
    }

    btnClose {
        onClicked: close()
    }
}
