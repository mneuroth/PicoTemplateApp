QT += quick quickcontrols2 qml svg printsupport core core-private

android {
    lessThan(QT_MAJOR_VERSION, 6): QT += purchasing
}

INCLUDEPATH += purchasing/qmltypes \
    purchasing/inapp \
    $$PWD

CONFIG += qmltypes
QML_IMPORT_PATH = $$PWD/qmfunctions.h
QML_IMPORT_NAME = PicoTemplateApp
QML_IMPORT_MAJOR_VERSION = 1

CONFIG += c++11

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        applicationdata.cpp \
        applicationui.cpp \
        storageaccess.cpp \
        shareutils.cpp \
        main.cpp

HEADERS += \
        applicationdata.h \
        applicationui.hpp \
        storageaccess.h \
        shareutils.hpp

greaterThan(QT_MAJOR_VERSION, 5): include($$PWD/purchasing/purchasing.pri)

RESOURCES += qml.qrc

TRANSLATIONS += \
    pico_de_DE.ts

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    android/AndroidManifest.xml \
    android/build.gradle \
    android/gradle.properties \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew \
    android/gradlew.bat \
    android/res/values/libs.xml \
    android/res/xml/filepaths.xml \
    android/src/de/mneuroth/activity/sharex/QShareActivity.java \
    android/src/de/mneuroth/utils/QSharePathResolver.java \
    android/src/de/mneuroth/utils/QShareUtils.java \
    android/src/de/mneuroth/utils/QStorageAccess.java \
    android/src/de/mneuroth/utils/Tuple.java \
    android/src/org/qtproject/qt/android/purchasing/Security.java \
    android/src/org/qtproject/qt/android/purchasing/InAppPurchase.java \
    android/src/org/qtproject/qt/android/purchasing/Base64.java \
    android/src/org/qtproject/qt/android/purchasing/Base64DecoderException.java

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

android {
    SOURCES += android/androidshareutils.cpp

    HEADERS += android/androidshareutils.hpp

    lessThan(QT_MAJOR_VERSION, 6): QT += androidextras

    equals(ANDROID_TARGET_ARCH, arm64-v8a) {
        ARCH_PATH = arm64
    }
    equals(ANDROID_TARGET_ARCH, armeabi-v7a) {
        ARCH_PATH = arm
    }
    equals(ANDROID_TARGET_ARCH, armeabi) {
        ARCH_PATH = arm
    }
    equals(ANDROID_TARGET_ARCH, x86)  {
        ARCH_PATH = i386
    }
    equals(ANDROID_TARGET_ARCH, x86_64)  {
        ARCH_PATH = x86_64
    }
    equals(ANDROID_TARGET_ARCH, mips)  {
        ARCH_PATH = mips
    }
    equals(ANDROID_TARGET_ARCH, mips64)  {
        ARCH_PATH = mips64
    }
}
