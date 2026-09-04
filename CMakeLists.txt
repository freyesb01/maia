cmake_minimum_required(VERSION 3.16 FATAL_ERROR)

project(maia-kde-plasma6
    VERSION 0.3.2
    LANGUAGES NONE
)

find_package(ECM 6.0 REQUIRED NO_MODULE)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)

install(
    DIRECTORY icons/
    DESTINATION ${KDE_INSTALL_DATADIR}/icons/Maia
)

install(
    DIRECTORY icons-dark/
    DESTINATION ${KDE_INSTALL_DATADIR}/icons/Maia-dark
)

install(
    DIRECTORY maia/
    DESTINATION ${KDE_INSTALL_DATADIR}/plasma/desktoptheme/Maia
)

install(
    DIRECTORY maia-dark/
    DESTINATION ${KDE_INSTALL_DATADIR}/plasma/desktoptheme/Maia-dark
)

install(
    DIRECTORY wallpapers/
    DESTINATION ${KDE_INSTALL_DATADIR}/wallpapers
)

install(
    DIRECTORY lookandfeel/contents/
    DESTINATION ${KDE_INSTALL_DATADIR}/plasma/look-and-feel/org.kde.maia/contents
)

install(
    FILES lookandfeel/metadata.json
    DESTINATION ${KDE_INSTALL_DATADIR}/plasma/look-and-feel/org.kde.maia
)

install(
    DIRECTORY lookandfeeldark/contents/
    DESTINATION ${KDE_INSTALL_DATADIR}/plasma/look-and-feel/org.kde.maiadark/contents
)

install(
    FILES lookandfeeldark/metadata.json
    DESTINATION ${KDE_INSTALL_DATADIR}/plasma/look-and-feel/org.kde.maiadark
)

install(
    DIRECTORY sddm-theme/
    DESTINATION ${KDE_INSTALL_DATADIR}/sddm/themes/maia
    PATTERN README.txt EXCLUDE
    PATTERN components EXCLUDE
    PATTERN dummydata EXCLUDE
)

install(
    DIRECTORY lookandfeel/contents/components/
    DESTINATION ${KDE_INSTALL_DATADIR}/sddm/themes/maia
    PATTERN README.txt EXCLUDE
)

install(
    FILES
        colors/Maia.colors
        colors/MaiaDark.colors
    DESTINATION ${KDE_INSTALL_DATADIR}/color-schemes
)
