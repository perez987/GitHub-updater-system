# GitHub Updater System

<a href="README.md">
    <img src="https://img.shields.io/badge/README-Inglés-blue" alt=“CHANGELOG releases”></a><br>
    
## Descripción general

Comprobador de actualizaciones ligero e integrado diseñado para aplicaciones SwiftUI publicadas en GitHub, que consulta la API de `releases` de GitHub para detectar versiones más recientes de la aplicación. No tiene dependencias de terceros (no se necesita Sparkle ni ningún framework similar).

## Cómo comprobar actualizaciones

Abre el menú **Acerca de esta aplicación** y haz clic en **Buscar actualizaciones…** (o pulsa `⌘ U`). La aplicación contacta con GitHub y, según el resultado, muestra una de las alertas descritas a continuación.

La misma comprobación está disponible de forma programática para verificaciones automáticas en segundo plano al iniciar la aplicación.

## Tipos de alerta

| Situación | Título | Mensaje |
|-----------|--------|---------|
| Hay una versión más reciente disponible | *Actualización disponible* | "APP X.X.X ya está disponible. ¿Deseas descargarla?" |
| Ya tienes la versión más reciente (solo si el usuario lo inicia) | *¡Estás al día!* | "APP X.X.X es actualmente la versión más reciente." |
| Error de red | *Error al comprobar actualizaciones* | "No se puede conectar al servidor de actualizaciones. Por favor, comprueba tu conexión a internet." |
| Error de API / análisis | *Error al comprobar actualizaciones* | "No se pudo obtener la información de actualización." |

Cuando hay una actualización disponible, al hacer clic en **Descargar actualización** se abre la página de versiones en el navegador predeterminado. Al hacer clic en **Más tarde** se cierra la alerta sin realizar ninguna acción.

## Lógica de enrutamiento de versiones

El comprobador adapta su llamada a la API de GitHub según el número de versión principal de la aplicación en ejecución.

- `Endpoint` de la API utilizado: `/repos/.../releases/latest`
- Utiliza el `endpoint` estándar de la *última versión*.

Este enrutamiento garantiza que los usuarios siempre estén siguiendo la versión más reciente de forma global.

## Comparación de versiones

Las versiones se comparan componente a componente después de eliminar la `v` inicial del nombre de la etiqueta (p. ej., `v3.0.2` → `3.0.2`). Los componentes que faltan se tratan como `0`, por lo que `3.1` es igual a `3.1.0`.

## Detalles técnicos

El actualizador está implementado como una clase de instancia única en `GitHubUpdateChecker.swift`:

```swift
GitHubUpdateChecker.shared.checkForUpdates(userInitiated: true)
```

Pasa `userInitiated: true` cuando el usuario activa la comprobación explícitamente (muestra la alerta *al día*). Pasa `userInitiated: false` para comprobaciones automáticas en segundo plano (la alerta *al día* se suprime para no interrumpir al usuario).

### Solicitud HTTP

```
GET https://api.github.com/repos/GHuser/GHrepo/releases/latest
Accept: application/vnd.github+json
X-GitHub-Api-Version: 2022-11-28
```

### Sin estado persistente

El comprobador no almacena ningún estado entre ejecuciones. Cada comprobación es una nueva solicitud HTTP y una comparación de versiones. No se escriben números de versión ni marcas de tiempo en el disco.

## Localización

Todas las cadenas visibles para el usuario están completamente localizadas a través de `Localizable.strings`. Las claves relevantes son:

| Clave | Valor predeterminado (inglés) |
|-------|-------------------------------|
| `Check for Updates…` | Check for Updates… |
| `UpdateAvailable` | Update Available |
| `UpdateAvailableInfo` | Application %@ is now available. Would you like to download it? |
| `DownloadUpdate` | Download Update |
| `UpdateLater` | Later |
| `UpToDate` | You're up to date! |
| `UpToDateInfo` | Application %@ is currently the latest version. |
| `UpdateCheckError` | Update Check Failed |
| `UpdateCheckFailed` | Failed to retrieve update information. |
| `UpdateCheckNetworkError` | Unable to connect to the update server. Please check your internet connection. |

## Implementación

### GitHubUpdateChecker.swift

Este es el único archivo de código necesario. Implementa el patrón Singleton, que garantiza que existirá una única instancia de la clase durante toda la ejecución de la aplicación. Proporciona un punto de acceso global y debe añadirse al proyecto Xcode.

Es necesario comprobar estas dos propiedades y reemplazarlas con el nombre del propietario y el nombre del repositorio de GitHub:

```swift
    private let owner = "GH-owner"
    private let repo = "GitHub-repo"
```

El resto del archivo puede usarse tal como está. Puedes ver el contenido de este archivo en [Files/Updater/GitHubUpdateChecker.swift](Files/Updater/GitHubUpdateChecker.swift)

### Archivos de idioma

Las cadenas utilizadas en el proceso de actualización están localizadas y traducidas a 5 idiomas: inglés, español, francés, alemán e italiano. Están disponibles en `Files/Resources`.

### Info.plist

No es obligatorio, pero se recomienda que las propiedades `BundleShortVersionString` y `BundleVersion` del archivo Info.plist no estén codificadas de forma fija, sino que se lean desde la configuración del proyecto:

```xml
<key>CFBundleShortVersionString</key>
<string>$(MARKETING_VERSION)</string>
<key>CFBundleVersion</key>
<string>$(CURRENT_PROJECT_VERSION)</string>
```

### Menú de comandos

El menú que comprueba las actualizaciones es fácil de implementar. Se añade un botón de menú con cuatro componentes, justo después de `.appInfo` ("Acerca de esta aplicación"):

- Cadena "Buscar actualizaciones"
- Imagen "arrow.triangle.2.circlepath"
- Enlace a la función `checkForUpdates`
- Atajo de teclado (`⌘ + U`).

```swift
        .commands {
            CommandGroup(after: .appInfo) {
                // Configuración para comprobar actualizaciones
                Button(NSLocalizedString("Check for Updates…", comment: "Menu item to check for app updates"),
                       systemImage: "arrow.triangle.2.circlepath") {
                    GitHubUpdateChecker.shared.checkForUpdates(userInitiated: true)
                }
                       .keyboardShortcut("u", modifiers: [.command])
            }            
        }
```
