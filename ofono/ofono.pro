openrepos {
    PREFIX = openrepos
    DEFINES += OPENREPOS
} else {
    PREFIX = harbour
}

NAME = logger-ofono
TARGET = $${PREFIX}-$${NAME}

app_settings {
    # This path is hardcoded in jolla-settings
    TRANSLATIONS_PATH = /usr/share/translations
} else {
    TRANSLATIONS_PATH = /usr/share/$${TARGET}/translations
}

CONFIG += sailfishapp link_pkgconfig
PKGCONFIG += sailfishapp mlite5 gio-2.0 gio-unix-2.0 glib-2.0
QT += dbus

WARNINGS = -Wall -Wno-unused-parameter -Wno-deprecated-declarations
EXTRA_CFLAGS = $$WARNINGS -fvisibility=hidden
DEFINES += QOFONOEXT_EXPORT=Q_DECL_HIDDEN
QMAKE_CXXFLAGS += $$EXTRA_CFLAGS
QMAKE_CFLAGS += $$EXTRA_CFLAGS

CONFIG(debug, debug|release) {
    QMAKE_CXXFLAGS_DEBUG *= -O0
    QMAKE_CFLAGS_DEBUG *= -O0
    DEFINES += DEBUG HARBOUR_DEBUG
} else {
    EXTRA_RELEASE_CFLAGS = -fPIC -flto -ffat-lto-objects
    QMAKE_CXXFLAGS += $$EXTRA_RELEASE_CFLAGS
    QMAKE_CFLAGS += $$EXTRA_RELEASE_CFLAGS
    QMAKE_LFLAGS += -fPIC -flto
}

# Directories
HARBOUR_LIB_DIR = $$_PRO_FILE_PWD_/../harbour-lib
LOGGER_LIB_DIR = $$_PRO_FILE_PWD_/../logger
QOFONOEXT_LIB_DIR = $$_PRO_FILE_PWD_/src/libqofonoext
QCONNMAN_LIB_DIR = $$_PRO_FILE_PWD_/../libconnman-qt

# Libraries
LOGGER_LIB = $$OUT_PWD/../logger/liblogger.a

PRE_TARGETDEPS += \
  $$LOGGER_LIB \
  $$HARBOUR_LIB

LIBS += \
  $$LOGGER_LIB \
  $$HARBOUR_LIB

OTHER_FILES += \
  icons/harbour-$${NAME}.svg \
  *.desktop \
  qml/*.qml \
  privileges/* \
  translations/*.ts

TARGET_DATA_DIR = /usr/share/$${TARGET}
TARGET_ICON_ROOT = /usr/share/icons/hicolor

logger_qml.files = $${LOGGER_LIB_DIR}/qml/*
logger_qml.path = $${TARGET_DATA_DIR}/qml
INSTALLS += logger_qml

INCLUDEPATH += \
  src \
  $${LOGGER_LIB_DIR}/include \
  $${HARBOUR_LIB_DIR}/include \
  $${QOFONOEXT_LIB_DIR}/src \
  $${QCONNMAN_LIB_DIR}/libconnman-qt

HEADERS += \
  $${QOFONOEXT_LIB_DIR}/src/qofonoextmodemmanager.h \
  $${QCONNMAN_LIB_DIR}/libconnman-qt/networktechnology.h

SOURCES += \
  src/main.cpp \
  $${QOFONOEXT_LIB_DIR}/src/qofonoext.cpp \
  $${QOFONOEXT_LIB_DIR}/src/qofonoextmodemmanager.cpp \
  $${QCONNMAN_LIB_DIR}/libconnman-qt/networktechnology.cpp

# harbour-lib QML components

HARBOUR_LIB_QML = $${HARBOUR_LIB_DIR}/qml
HARBOUR_QML_COMPONENTS = \
    $${HARBOUR_LIB_QML}/HarbourHighlightIcon.qml \
    $${HARBOUR_LIB_QML}/HarbourHintIconButton.qml \
    $${HARBOUR_LIB_QML}/HarbourShareMethodList.qml

qml_components.files = $${HARBOUR_QML_COMPONENTS}
qml_components.path = $${TARGET_DATA_DIR}/qml/harbour
INSTALLS += qml_components

# D-Bus interfaces
DBUS_INTERFACES += net_connman_technology
net_connman_technology.files = $${QCONNMAN_LIB_DIR}/libconnman-qt/connman_technology.xml

OTHER_FILES += \
    $${net_connman_technology.files}

# Settings
app_settings {
    settings_json.files = $${LOGGER_LIB_DIR}/settings/$${TARGET}.json
    settings_json.path = /usr/share/jolla-settings/entries/
    settings_json.extra = sed s/harbour-logger/$${TARGET}/g $${LOGGER_LIB_DIR}/settings/harbour-logger.json > $$eval(settings_json.files)
    settings_json.CONFIG += no_check_exist
    settings_qml.files = $${LOGGER_LIB_DIR}/settings/settings.qml
    settings_qml.path = /usr/share/$${TARGET}/settings/
    INSTALLS += settings_qml settings_json
}

# Priveleges
privileges.files = privileges/$${PREFIX}-logger-ofono
privileges.path = /usr/share/mapplauncherd/privileges.d/
INSTALLS += privileges

# Icons
ICON_SIZES = 86 108 128 172 256
for(s, ICON_SIZES) {
    icon_target = icon$${s}
    icon_dir = icons/$${s}x$${s}
    $${icon_target}.path = /usr/share/icons/hicolor/$${s}x$${s}/apps
    openrepos {
        $${icon_target}.CONFIG += no_check_exist
        $${icon_target}.files = $${OUT_PWD}/$${icon_dir}/$${TARGET}.png
        $${icon_target}.extra = mkdir -p \"$${OUT_PWD}/$${icon_dir}\" && \
            cp \"$${_PRO_FILE_PWD_}/$${icon_dir}/harbour-$${NAME}.png\" \"$${OUT_PWD}/$${icon_dir}/$${TARGET}.png\"
    } else {
        $${icon_target}.files = $${icon_dir}/$${TARGET}.png
    }
    INSTALLS += $${icon_target}
}

# Translations
TRANSLATION_IDBASED=-idbased
TRANSLATION_SOURCES = \
  $${_PRO_FILE_PWD_}/src \
  $${_PRO_FILE_PWD_}/qml \
  $${LOGGER_LIB_DIR}/qml \
  $${LOGGER_LIB_DIR}/settings

TRANSLATION_FILES = \
  $${NAME} \
  $${NAME}-fr \
  $${NAME}-nl \
  $${NAME}-pl \
  $${NAME}-ru \
  $${NAME}-sv \
  $${NAME}-zh_CN

for(t, TRANSLATION_FILES) {
    suffix = $$replace(t,-,_)
    in = $${_PRO_FILE_PWD_}/translations/harbour-$${t}
    out = $${OUT_PWD}/translations/$${PREFIX}-$${t}

    lupdate_target = lupdate_$$suffix
    $${lupdate_target}.commands = lupdate -noobsolete -locations none $${TRANSLATION_SOURCES} -ts \"$${in}.ts\" && \
        mkdir -p \"$${OUT_PWD}/translations\" &&  [ \"$${in}.ts\" != \"$${out}.ts\" ] && \
        cp -af \"$${in}.ts\" \"$${out}.ts\" || :

    qm_target = qm_$$suffix
    $${qm_target}.path = $$TRANSLATIONS_PATH
    $${qm_target}.depends = $${lupdate_target}
    $${qm_target}.commands = lrelease $$TRANSLATION_IDBASED \"$${out}.ts\" && \
        $(INSTALL_FILE) \"$${out}.qm\" $(INSTALL_ROOT)$${TRANSLATIONS_PATH}/

    QMAKE_EXTRA_TARGETS += $${lupdate_target} $${qm_target}
    INSTALLS += $${qm_target}
    OTHER_FILES += $${in}.ts
}
