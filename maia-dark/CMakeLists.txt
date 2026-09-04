install(
    FILES
        colors
        metadata.json
    DESTINATION
        ${KDE_INSTALL_DATADIR}/plasma/desktoptheme/maia-dark
)

file(GLOB widgets widgets/*.svgz)
install(
    FILES ${widgets}
    DESTINATION ${KDE_INSTALL_DATADIR}/plasma/desktoptheme/maia-dark/widgets
)

file(GLOB dialogs dialogs/*.svgz)
install(
    FILES ${dialogs}
    DESTINATION ${KDE_INSTALL_DATADIR}/plasma/desktoptheme/maia-dark/dialogs
)

file(GLOB icons icons/*.svgz)
install(
    FILES ${icons}
    DESTINATION ${KDE_INSTALL_DATADIR}/plasma/desktoptheme/maia-dark/icons
)
