#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include <QLocale>
#include <QTranslator>
#include <QIcon>
#include <QtGlobal>
#include <QDir>
#include <QFile>
#include <QDateTime>
#if QT_VERSION >= 0x060000
#include <QQuickStyle>
#endif

#include "applicationdata.h"

#ifdef _WITH_STORAGE_ACCESS
#include "storageaccess.h"
#endif
#ifdef _WITH_SHARING
#include "shareutils.hpp"
#endif
#if defined(Q_OS_ANDROID)
#include "applicationui.hpp"
#endif

#undef _WITH_QDEBUG_REDIRECT
#undef _WITH_ADD_TO_LOG

static qint64 g_iLastTimeStamp = 0;

void AddToLog(const QString & msg)
{
#ifdef _WITH_ADD_TO_LOG
    QString sFileName("/sdcard/Texte/picoapptpl_qdebug.log");
    if( !QDir("/sdcard/Texte").exists() )
    {
        sFileName = "D:\\Users\\micha\\Documents\\git_projects\\build-pico-Desktop_Qt_6_2_2_MinGW_64_bit-Debug\\picoapp_qdebug.log";
        sFileName = "picoapptpl_qdebug.log";
    }
    QFile outFile(sFileName);
    bool ok = outFile.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Unbuffered);
    QTextStream ts(&outFile);
    qint64 now = QDateTime::currentMSecsSinceEpoch();
    qint64 delta = now - g_iLastTimeStamp;
    g_iLastTimeStamp = now;
    ts << delta << " ";
    ts << msg << Qt::endl;
    //qDebug() << delta << " " << msg << Qt::endl;
    outFile.close();
#else
    Q_UNUSED(msg)
#endif
}

#ifdef _WITH_QDEBUG_REDIRECT
#include <QDebug>
void PrivateMessageHandler(QtMsgType type, const QMessageLogContext & context, const QString & msg)
{
    QString txt;
    switch (type) {
    case QtDebugMsg:
        txt = QString("Debug: %1 (%2:%3, %4)").arg(msg).arg(context.file).arg(context.line).arg(context.function);
        break;
    case QtWarningMsg:
        txt = QString("Warning: %1 (%2:%3, %4)").arg(msg).arg(context.file).arg(context.line).arg(context.function);
        break;
    case QtCriticalMsg:
        txt = QString("Critical: %1 (%2:%3, %4)").arg(msg).arg(context.file).arg(context.line).arg(context.function);
        break;
    case QtFatalMsg:
        txt = QString("Fatal: %1 (%2:%3, %4)").arg(msg).arg(context.file).arg(context.line).arg(context.function);
        break;
    case QtInfoMsg:
        txt = QString("Info: %1 (%2:%3, %4)").arg(msg).arg(context.file).arg(context.line).arg(context.function);
        break;
    }
    AddToLog(txt);
}
#endif

int main(int argc, char *argv[])
{
    //AddToLog("INIT==> PicoAppTemplate <==");
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

#ifdef _WITH_QDEBUG_REDIRECT
    qInstallMessageHandler(PrivateMessageHandler);
#endif
    //AddToLog("INIT==> PicoAppTemplate <== point2");

    QGuiApplication app(argc, argv);
    app.setOrganizationName("mneuroth.de");     // Computer/HKEY_CURRENT_USER/Software/mneuroth.de
    app.setOrganizationDomain("mneuroth.de");
    app.setApplicationName("PicoTemplateApp");
    app.setWindowIcon(QIcon(":/pico.png"));

#if QT_VERSION >= 0x060000
    QQuickStyle::setStyle("Material"); // Basic, Fusion, Imagine, macOS, Material, Universal, Windows
#endif

    // QTranslator qtTranslator;
    // // WASM --> returns "c"
    // QString sLanguage = QLocale::system().name().mid(0,2).toLower();
    // // for testing languages:
    // //sLanguage = "nl";
    // //sLanguage = "fr";
    // //sLanguage = "es";
    // QString sResource = ":/translations/pico_" + sLanguage + "_" + sLanguage.toUpper() + ".qm";
    // /*bool ok1 =*/ qtTranslator.load(sResource);
    // /*bool ok2 =*/ app.installTranslator(&qtTranslator);

    QTranslator translator;
    const QStringList uiLanguages = QLocale::system().uiLanguages();
    for (const QString &locale : uiLanguages) {
        const QString baseName = "pico_" + QLocale(locale).name();
        if (translator.load(":/i18n/" + baseName)) {
            app.installTranslator(&translator);
            break;
        }
    }

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

#if defined(Q_OS_ANDROID)
    ApplicationUI appui;
#endif
    StorageAccess aStorageAccess;

#if defined(Q_OS_ANDROID)
    QObject::connect(&app, SIGNAL(applicationStateChanged(Qt::ApplicationState)), &appui, SLOT(onApplicationStateChanged(Qt::ApplicationState)));
    QObject::connect(&app, SIGNAL(saveStateRequest(QSessionManager &)), &appui, SLOT(onSaveStateRequest(QSessionManager &)), Qt::DirectConnection);
    QObject::connect(&appui, SIGNAL(requestApplicationQuit()), &app, SLOT(quit())/* , Qt::QueuedConnection*/);
#endif

#if defined(Q_OS_ANDROID)
    ApplicationData data(0, appui.GetShareUtils(), aStorageAccess, engine);
    QObject::connect(&app, SIGNAL(applicationStateChanged(Qt::ApplicationState)), &data, SLOT(sltApplicationStateChanged(Qt::ApplicationState)));
#else
    ApplicationData data(0, new ShareUtils(), aStorageAccess, engine);
#endif

    engine.rootContext()->setContextProperty("applicationData", &data);
#ifdef _WITH_STORAGE_ACCESS
    engine.rootContext()->setContextProperty("storageAccess", &aStorageAccess);
#endif

    engine.load(url);

    return app.exec();
}
