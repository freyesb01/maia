install(
    FILES
        colors
        metadata.json
    DESTINATION
        ${KDE_INSTALL_DATADIR}/plasma/desktoptheme/maia
)

file(GLOB widgets widgets/*.svgz)
install(
    FILES ${widgets}
    DESTINATION ${KDE_INSTALL_DATADIR}/plasma/desktoptheme/maia/widgets
)

file(GLOB dialogs dialogs/*.svgz)
install(
    FILES ${dialogs}
    DESTINATION ${KDE_INSTALL_DATADIR}/plasma/desktoptheme/maia/dialogs
)

file(GLOB icons icons/*.svgz)
install(
    FILES ${icons}
    DESTINATION ${KDE_INSTALL_DATADIR}/plasma/desktoptheme/maia/icons
)
