#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QQmlContext>

#include <QtGlobal>
#include <QDir>
#include <QFile>
#include <QDateTime>
#include <QIcon>
#include <QTranslator>

#include "applicationdata.h"
#include "applicationui.hpp"
#include "shareutils.hpp"
#include "storageaccess.h"

#undef _WITH_QDEBUG_REDIRECT
#undef _WITH_ADD_TO_LOG

static qint64 g_iLastTimeStamp = 0;

void AddToLog(const QString & msg)
{
#ifdef _WITH_ADD_TO_LOG
    QString sFileName("/sdcard/Texte/picoapp_qdebug.log");
    if( !QDir("/sdcard/Texte").exists() )
    {
        sFileName = "picoapp_qdebug.log";
    }
    QFile outFile(sFileName);
    outFile.open(QIODevice::WriteOnly | QIODevice::Append);
    QTextStream ts(&outFile);
    qint64 now = QDateTime::currentMSecsSinceEpoch();
    qint64 delta = now - g_iLastTimeStamp;
    g_iLastTimeStamp = now;
    ts << delta << " ";
    ts << msg << endl;
    qDebug() << delta << " " << msg << endl;
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
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

#ifdef _WITH_QDEBUG_REDIRECT
    qInstallMessageHandler(PrivateMessageHandler);
#endif

    QGuiApplication app(argc, argv);
    app.setOrganizationName("mneuroth.de");     // Computer/HKEY_CURRENT_USER/Software/mneuroth.de
    app.setOrganizationDomain("mneuroth.de");
    app.setApplicationName("PicoApp");
    app.setWindowIcon(QIcon(":/pico.png"));

    QTranslator qtTranslator;
    // WASM --> returns "c"
    QString sLanguage = QLocale::system().name().mid(0,2).toLower();
    // for testing languages:
    //sLanguage = "nl";
    //sLanguage = "fr";
    //sLanguage = "es";
    QString sResource = ":/translations/pico_" + sLanguage + "_" + sLanguage.toUpper() + ".qm";
    /*bool ok1 =*/ qtTranslator.load(sResource);
    /*bool ok2 =*/ app.installTranslator(&qtTranslator);

#if defined(Q_OS_ANDROID)
    ApplicationUI appui;
#endif

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

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
    engine.rootContext()->setContextProperty("storageAccess", &aStorageAccess);

    engine.load(url);

    return app.exec();
}
