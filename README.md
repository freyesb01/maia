# Maia KDE — Port a Plasma 6

![Plasma](https://img.shields.io/badge/Plasma-6.x-blue) ![Estado](https://img.shields.io/badge/estado-listo-success) ![Licencia](https://img.shields.io/badge/licencia-GPLv3-lightgrey)

## Introducción

Maia es el tema visual con el que **Manjaro Linux** vistió su escritorio Plasma por defecto durante buena parte de su historia: una paleta verde-azulada, tipografía limpia y una identidad reconocible que muchas personas asocian directamente con su primer contacto con Manjaro. A diferencia de Arc o Materia, Maia no viene del equipo de PapirusDevelopmentTeam: su origen es el propio equipo de **Manjaro Linux**.

Este repositorio toma esa identidad visual y la porta a KDE Plasma 6, sobre Qt6 y KDE Frameworks 6 (KF6). Es, otra vez, un trabajo de empaquetado e instalación, no un rediseño: la paleta y la geometría del tema son las mismas que reconocerías en Manjaro con Plasma 5.

## Qué problema resuelve este port

El cambio de Plasma 5 a Plasma 6 trae consigo un cambio de runtime (Qt5 a Qt6) y de convenciones de metadatos en KPackage. Un tema pensado y empaquetado para Plasma 5 no se traslada de forma automática ni segura a Plasma 6: las rutas de instalación, la forma de declarar metadatos de un Look-and-Feel y la manera en que Plasma resuelve iconos y esquemas de color han cambiado lo suficiente como para que una instalación heredada deje componentes a medio aplicar o directamente inutilizables.

Maia, además, tiene una particularidad frente a Arc y Materia: incluye su propio conjunto de iconos. Instalar iconos correctamente en el sistema requiere respetar la convención de directorios de temas de iconos (`icons/<NombreDelTema>/...`) para que el sistema de resolución de iconos de Qt/KDE los reconozca como un tema completo y no como archivos sueltos. Este repositorio se encarga de aplicar esa convención de forma consistente.

## Qué se conserva y qué se moderniza

La paleta de color, el diseño de los iconos y la identidad visual de Maia se mantienen intactos: este port no reinterpreta el trabajo original del equipo de Manjaro. Lo que cambia es exclusivamente el mecanismo de construcción e instalación, que ahora pasa por un único `CMakeLists.txt` apoyado en Extra CMake Modules (ECM) y en las rutas de instalación estandarizadas de KDE (`KDEInstallDirs`), en lugar de scripts o copias manuales.

## Componentes incluidos

- **Iconos**: el tema `Maia` (a partir de `icons/`) y el tema `Maia-dark` (a partir de `icons-dark/`).
- **Plasma Desktop Theme**: `Maia` (a partir de `maia/`) y `Maia-dark` (a partir de `maia-dark/`), que definen el aspecto de los elementos propios del shell de Plasma.
- **Look-and-Feel**: `org.kde.maia` (a partir de `lookandfeel/`) y `org.kde.maiadark` (a partir de `lookandfeeldark/`), cada uno con su propio `metadata.json` y su carpeta `contents/`.
- **Esquemas de color**: `Maia.colors` y `MaiaDark.colors`, a partir de `colors/`.
- **SDDM**: un tema llamado `maia`, construido combinando el contenido de `sddm-theme/` con los componentes QML reutilizados desde `lookandfeel/contents/components/` (ver la sección de SDDM más abajo para el detalle de por qué se combinan ambos).
- **Wallpapers**: a partir de `wallpapers/`.

Este repositorio **no incluye** perfiles de Konsole, temas de Kvantum ni skins de Yakuake: esos componentes simplemente no forman parte de la estructura de Maia.

## Organización del repositorio

```text
maia/
├── CMakeLists.txt
├── colors/
│   ├── Maia.colors
│   └── MaiaDark.colors
├── icons/
├── icons-dark/
├── maia/
├── maia-dark/
├── lookandfeel/
│   ├── metadata.json
│   └── contents/
├── lookandfeeldark/
│   ├── metadata.json
│   └── contents/
├── sddm-theme/
├── wallpapers/
└── dir.txt
```

`dir.txt` es un archivo auxiliar del propio repositorio; no se instala en el sistema ni forma parte de ningún componente visual, así que no lo vas a encontrar mencionado en las reglas de instalación del `CMakeLists.txt`.

## Decisiones técnicas de CMake

```cmake
cmake_minimum_required(VERSION 3.16 FATAL_ERROR)

project(maia-kde
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
```

Algunos puntos de este archivo merecen explicación aparte:

**`cmake_minimum_required(VERSION 3.16 FATAL_ERROR)`.** El modificador `FATAL_ERROR` hace que, si la versión de CMake instalada en el sistema es menor a 3.16, la configuración se detenga inmediatamente con un error claro, en lugar de continuar con un comportamiento potencialmente inconsistente en versiones antiguas de CMake que no soportan todas las funciones usadas en este archivo.

**Por qué Maia también necesita ECM y `KDEInstallDirs`.** Igual que Materia, Maia instala un tema de SDDM, un tipo de recurso que no forma parte de las rutas genéricas que define `GNUInstallDirs`. `KDEInstallDirs`, provisto por Extra CMake Modules (ECM), añade las rutas específicas del ecosistema KDE que este proyecto necesita para resolver consistentemente dónde va cada recurso, independientemente de la distribución sobre la que se instale.

**Por qué el tema de SDDM se arma combinando dos `install()` distintos.** La primera regla copia el contenido de `sddm-theme/` hacia `sddm/themes/maia`, excluyendo explícitamente `README.txt`, una carpeta `components` y una carpeta `dummydata` que existen en el árbol fuente pero no deben terminar instaladas tal cual. La segunda regla toma los componentes QML que viven dentro de `lookandfeel/contents/components/` —los mismos que usa el Look-and-Feel para la pantalla de bloqueo— y los copia también dentro de `sddm/themes/maia`. Esto tiene sentido de diseño: la pantalla de login (SDDM) y la pantalla de bloqueo (parte del Look-and-Feel de sesión) suelen compartir elementos visuales —reloj, campo de contraseña, fondo— y reutilizar el mismo conjunto de componentes QML entre ambas evita mantener dos copias del mismo código con el riesgo de que se desincronicen visualmente.

## Requisitos

- CMake >= 3.16
- Extra CMake Modules (ECM) >= 6.0
- KDE Plasma 6
- Qt6 (entorno de ejecución; este repositorio no compila contra Qt)

## Compilación e instalación

Primero obtén el código fuente. Sustituye `<usuario-de-github>` por la cuenta u organización real donde esté alojado el repositorio:

```bash
git clone https://github.com/freyesb01/maia.git
cd maia
```

Con el código ya en tu máquina:

```bash
cmake -S . -B build -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build
sudo cmake --install build
```

`cmake -S . -B build` configura el proyecto en un directorio de build separado del árbol de fuentes, lo que te permite descartarlo por completo sin afectar el repositorio. `cmake --build build` invoca el sistema de construcción generado; como el proyecto declara `LANGUAGES NONE`, no hay compilación real que ejecutar, solo el procesamiento de los targets internos de CMake, incluido el de instalación. `cmake --install build` es el paso que efectivamente copia cada recurso a su `DESTINATION`, combinada con `CMAKE_INSTALL_PREFIX`; como el prefijo del ejemplo es `/usr`, directorio propiedad de `root`, este último comando necesita `sudo`.

## Instalación de usuario en `$HOME/.local`

```bash
cmake -S . -B build-user -DCMAKE_INSTALL_PREFIX="$HOME/.local"
cmake --build build-user
cmake --install build-user
```

Esta ruta es preferible para pruebas: no requiere privilegios de administrador y es completamente reversible borrando la carpeta correspondiente dentro de `$HOME/.local/share`. Igual que en Materia, el tema de SDDM instalado bajo este prefijo **no será detectado por SDDM**, porque este último solo lee temas desde rutas del sistema. Para probar la pantalla de login necesitas instalar con `CMAKE_INSTALL_PREFIX=/usr`.

## Cómo probar la instalación

Para iconos, Plasma Desktop Theme, Look-and-Feel, colores y wallpapers, reinicia el shell de Plasma:

```bash
kquitapp6 plasmashell && kstart plasmashell
```

Para confirmar que el tema de iconos se aplicó correctamente, revisa el selector de iconos en Configuración del sistema → Apariencia → Iconos, donde debería aparecer `Maia` o `Maia-dark` como opción disponible.

Para el tema de SDDM, la validación real solo ocurre al cerrar sesión (o reiniciar el servicio `sddm`) y observar la pantalla de login.

## Cómo verificar las rutas instaladas

```bash
cat build/install_manifest.txt
```

```bash
find "$HOME/.local/share" -iname '*maia*'
```

o, para una instalación en todo el sistema:

```bash
find /usr/share -iname '*maia*'
```

Este `CMakeLists.txt` solo instala lo que está explícitamente declarado en sus reglas `install()`: iconos, Plasma Desktop Theme, Look-and-Feel (con sus dos variantes), colores, wallpapers y el tema de SDDM ya combinado. Archivos como `README.md`, `AUTHORS`, `LICENSE`, `dir.txt` o cualquier imagen de portada no se instalan; permanecen únicamente como parte del repositorio.

## Cómo activar cada componente desde KDE

1. **Apariencia global**: Apariencia → Apariencia global → **Maia** o **Maia Dark**.
2. **Estilo de Plasma**: Apariencia → Estilo de Plasma → **Maia** o **Maia-dark**.
3. **Iconos**: Apariencia → Iconos → **Maia** o **Maia-dark**.
4. **Colores**: Apariencia → Colores → **Maia** o **MaiaDark**.
5. **SDDM**: ver la sección siguiente, porque este paso requiere permisos administrativos.

## Consideraciones de SDDM

El tema de login no se activa desde Configuración del sistema como el resto de los componentes: SDDM lee su configuración desde archivos bajo `/etc/sddm.conf.d/`, que pertenecen a `root`, y cambiarlo afecta al gestor de inicio de sesión de todo el sistema, no solo a tu usuario. Por eso este paso requiere permisos administrativos por diseño, y no por una limitación del port:

```bash
sudo mkdir -p /etc/sddm.conf.d
echo -e "[Theme]\nCurrent=maia" | sudo tee /etc/sddm.conf.d/theme.conf
sudo systemctl restart sddm
```

`sudo systemctl restart sddm` cierra de inmediato la sesión gráfica activa si la estás ejecutando sobre una sesión iniciada por SDDM; guarda tu trabajo antes de ejecutar este comando.

Este repositorio no incluye componentes de Kvantum, Konsole ni Yakuake, así que no hay nada que configurar para ellos en este proyecto.

## Limpieza, reinstalación y desinstalación

Reinstalar no requiere borrar nada primero: puedes volver a ejecutar `cmake --build` y `cmake --install` sobre el mismo directorio de build.

Para partir de cero en la configuración:

```bash
rm -rf build
rm -rf build-user
```

Para desinstalar los archivos que quedaron copiados en el sistema:

```bash
sudo xargs rm -v < build/install_manifest.txt
```

Si el tema de SDDM estaba activo y lo desinstalas, recuerda revertir `/etc/sddm.conf.d/theme.conf` a un tema válido antes de reiniciar `sddm`, para evitar que la pantalla de login falle al iniciar.

Reconstruir la caché de KDE con `kbuildsycoca6 --noincremental` no es un paso obligatorio; solo resulta útil si, tras instalar o quitar un componente, Plasma no refleja el cambio en la sesión activa.

## Problemas conocidos o límites

- El tema de SDDM instalado bajo `$HOME/.local` no será detectado por SDDM, por la misma razón que en Materia: SDDM no lee rutas de usuario.
- No existe una matriz de pruebas documentada por distribución; si encuentras un problema en tu configuración particular, repórtalo en el repositorio.
- `TODO`: confirmar en un archivo `AUTHORS` del repositorio si existen colaboradores adicionales involucrados específicamente en este port, más allá de la atribución al equipo original de Manjaro.

## Créditos y licencia

- Diseño visual original del tema Maia: **equipo de Manjaro Linux**.
- Port a Plasma 6 y mantenimiento de este repositorio: **Fredy Reyes**.

Licencia: **GPLv3**. Consulta el archivo `LICENSE` del repositorio para el texto completo.
