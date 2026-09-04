cmake_minimum_required(VERSION 3.16)

project(maia-icons NONE)

include(KDEInstallDirs)

set(ICON_INSTALL_DIR "${KDE_INSTALL_DATADIR}/icons")

set(maia_icon_dirs actions apps categories devices emblems extras mimetypes places status)

set(MAIA_INSTALL_DIR ${ICON_INSTALL_DIR}/maia)

install(
    DIRECTORY ${maia_icon_dirs}
    DESTINATION ${MAIA_INSTALL_DIR}
    PATTERN "*.sh" EXCLUDE
)

install(
    FILES index.theme
    DESTINATION ${MAIA_INSTALL_DIR}
)
