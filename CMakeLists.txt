cmake_minimum_required(VERSION 3.16)
project(pico VERSION 1.0 LANGUAGES C CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(QT NAMES Qt5 Qt6 REQUIRED COMPONENTS Core)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Gui PrintSupport Qml Quick QuickControls2 Svg)
#find_package(Qt${QT_VERSION_MAJOR} OPTIONAL_COMPONENTS AndroidExtras Purchasing)

qt_standard_project_setup()

qt_add_executable(pico WIN32 MACOSX_BUNDLE
    applicationdata.cpp applicationdata.h
    applicationui.cpp applicationui.hpp
    main.cpp
    shareutils.cpp shareutils.hpp
    storageaccess.cpp storageaccess.h
)
qt_add_qml_module(pico
    URI pico
    VERSION ${PROJECT_VERSION}
    QML_FILES
        main.qml
        HomeForm.ui.qml
        Page1Form.ui.qml
        Page2Form.ui.qml
        MobileFileDialog.qml
        MobileFileDialogForm.ui.qml
        NativeFileDialog.qml
        SettingsDialog.qml
        SettingsDialogForm.ui.qml
        AboutDialog.qml
        AboutDialogForm.ui.qml
    RESOURCES
        qtquickcontrols2.conf
        pico.png
        images/menu.svg
        images/menu_bars.svg
        images/back.svg
        images/share.svg
        images/search.svg
        images/replace.svg
        images/settings.svg
        images/close.svg
        images/left-arrow.svg
        images/right-arrow.svg
        images/back-arrow.svg
        images/redo-arrow.svg
        images/open-folder-with-document.svg
        images/floppy-disk.svg
    NO_RESOURCE_TARGET_PATH
)
set_source_files_properties("images/back-arrow.svg"
    PROPERTIES QT_RESOURCE_ALIAS "back-arrow.svg"
)
set_source_files_properties("images/back.svg"
    PROPERTIES QT_RESOURCE_ALIAS "back.svg"
)
set_source_files_properties("images/close.svg"
    PROPERTIES QT_RESOURCE_ALIAS "close.svg"
)
set_source_files_properties("images/floppy-disk.svg"
    PROPERTIES QT_RESOURCE_ALIAS "floppy-disk.svg"
)
set_source_files_properties("images/left-arrow.svg"
    PROPERTIES QT_RESOURCE_ALIAS "left-arrow.svg"
)
set_source_files_properties("images/menu.svg"
    PROPERTIES QT_RESOURCE_ALIAS "menu.svg"
)
set_source_files_properties("images/menu_bars.svg"
    PROPERTIES QT_RESOURCE_ALIAS "menu_bars.svg"
)
set_source_files_properties("images/open-folder-with-document.svg"
    PROPERTIES QT_RESOURCE_ALIAS "open-folder-with-document.svg"
)
set_source_files_properties("images/redo-arrow.svg"
    PROPERTIES QT_RESOURCE_ALIAS "redo-arrow.svg"
)
set_source_files_properties("images/replace.svg"
    PROPERTIES QT_RESOURCE_ALIAS "replace.svg"
)
set_source_files_properties("images/right-arrow.svg"
    PROPERTIES QT_RESOURCE_ALIAS "right-arrow.svg"
)
set_source_files_properties("images/search.svg"
    PROPERTIES QT_RESOURCE_ALIAS "search.svg"
)
set_source_files_properties("images/settings.svg"
    PROPERTIES QT_RESOURCE_ALIAS "settings.svg"
)
set_source_files_properties("images/share.svg"
    PROPERTIES QT_RESOURCE_ALIAS "share.svg"
)

# Avoid collision between executable name and QML module directory (QTBUG-98568).
if(NOT WIN32 AND NOT APPLE)
    set_property(TARGET pico PROPERTY OUTPUT_NAME pico_app)
endif()

target_link_libraries(pico PRIVATE
    Qt::Core
    Qt::CorePrivate
    Qt::Gui
    Qt::PrintSupport
    Qt::Qml
    Qt::Quick
    Qt::QuickControls2
    Qt::Svg
)


# Resources:
set(qml1_resource_files
    "pico_de_DE.qm"
)

qt_add_resources(pico "qml1"
    PREFIX
        "/translations"
    FILES
        ${qml1_resource_files}
)

if(ANDROID)
    target_sources(pico PUBLIC
        android/androidshareutils.cpp android/androidshareutils.hpp
    )
endif()

if((ANDROID) AND ((QT_VERSION_MAJOR LESS 6)))
    target_link_libraries(pico PRIVATE
        Qt::AndroidExtras
        Qt::Purchasing
    )
endif()

install(TARGETS pico
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

qt_generate_deploy_qml_app_script(
    TARGET pico
    FILENAME_VARIABLE deploy_script
    NO_UNSUPPORTED_PLATFORM_ERROR
    DEPLOY_USER_QML_MODULES_ON_UNSUPPORTED_PLATFORM
    MACOS_BUNDLE_POST_BUILD
)
install(SCRIPT ${deploy_script})
