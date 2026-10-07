# CinemaxPlus: Pruebas y Mantenimiento

Aplicación web de streaming (estilo Netflix) desarrollada en **PHP + MySQL**, creada como proyecto para la materia de **Pruebas y Mantenimiento de Software**. Además de la funcionalidad de la plataforma, el repositorio incluye **pruebas unitarias (PHPUnit)** y una **prueba de interfaz automatizada (Selenium WebDriver)**.

---

## Tabla de contenido

- [Funcionalidades](#funcionalidades)
- [Tecnologías](#tecnologías)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Base de datos](#base-de-datos)
- [Instalación](#instalación)
- [Configuración](#configuración)
- [Ejecución de las pruebas](#ejecución-de-las-pruebas)
- [Flujo de la aplicación](#flujo-de-la-aplicación)
- [Limitaciones conocidas y mejoras de mantenimiento](#limitaciones-conocidas-y-mejoras-de-mantenimiento)
- [Autor](#autor)

---

## Funcionalidades

- **Registro e inicio de sesión** de clientes con validación en el cliente (JavaScript) y en el servidor (PHP).
- **Membresías**: plan *regular* (acceso directo) y plan *premium* (con pantalla de pago simulado).
- **Perfiles múltiples** por cuenta: crear y eliminar perfiles, cada uno con su género favorito.
- **Repertorio personalizado**: contenido destacado y recomendado según el género favorito del perfil, más una sección de populares aleatorios.
- **Lista de favoritos** por perfil: agregar desde el repertorio y eliminar desde la sección de favoritos.
- **Cierre de sesión** que destruye la sesión activa.
- **Catálogo inicial** de 24 títulos en 4 géneros: Acción, Comedia, Terror y Drama.

## Tecnologías

| Área | Herramienta |
|---|---|
| Lenguaje backend | PHP 7.4 o superior (desarrollado con PHP 8.3) |
| Base de datos | MySQL (acceso mediante PDO) |
| Frontend | HTML5, CSS3, JavaScript |
| Gestor de dependencias | Composer |
| Pruebas unitarias | PHPUnit ^9.5 |
| Pruebas de interfaz | php-webdriver ^1.13 + Selenium Server + Chrome |

## Estructura del proyecto

```
pruebas-y-mantenimiento/
├── README.md
└── cinemax_plus/
    ├── cinemax_plus.sql        # Script de la base de datos (estructura + datos de ejemplo)
    ├── composer.json           # Dependencias y autoload (namespace Cinemax\ → src/)
    ├── phpunit.xml             # Configuración de PHPUnit (suites Unit y Browser)
    ├── db.php                  # Conexión PDO a MySQL
    ├── estilos_cinemax.css     # Estilos de toda la aplicación
    ├── home.php                # Página de bienvenida (landing)
    ├── registro.php            # Registro de clientes
    ├── login.php               # Inicio de sesión
    ├── logout.php              # Cierre de sesión
    ├── membresia.php           # Selección de plan (regular / premium)
    ├── pago.php                # Pago simulado del plan premium
    ├── usuarios.php            # Gestión y selección de perfiles
    ├── repertorio.php          # Catálogo personalizado por perfil
    ├── favoritos.php           # Lista de favoritos del perfil
    ├── src/
    │   └── Auth.php            # Lógica de validación testeable (clase Cinemax\Auth)
    └── tests/
        ├── Unit/
        │   └── AuthTest.php            # Pruebas unitarias de Auth
        └── Browser/
            └── LoginSeleniumTest.php   # Prueba end-to-end del login con Selenium
```

## Base de datos

El archivo `cinemax_plus.sql` crea la base de datos `cinemax_plus` con las siguientes tablas:

| Tabla | Descripción |
|---|---|
| `cliente` | Cuentas registradas (correo único, contraseña, nombre, fecha de registro). |
| `usuarios` | Perfiles de cada cliente. La clave `perfil_key` tiene el formato `<id_cliente>_<nombre_normalizado>`. Incluye el género favorito (`cat_fav`). |
| `contenido` | Catálogo de películas y series (título, género, URL de la imagen). |
| `favs` | Favoritos por perfil (relación `perfil_key` ↔ `id_contenido`). |
| `membresias` | Membresías activas del cliente (`regular` / `premium`) con fecha de inicio y vencimiento. |

> El dump incluye un cliente de ejemplo (`carlos@gmail.com`) con datos de prueba. Úsalo solo en entorno local.

## Instalación

### Requisitos previos

- [XAMPP](https://www.apachefriends.org/) o similar (Apache + PHP + MySQL)
- [Composer](https://getcomposer.org/)
- Para las pruebas de navegador: [Selenium Server](https://www.selenium.dev/downloads/), Google Chrome y ChromeDriver

### Pasos

1. **Clona o descarga** el repositorio y copia la carpeta `cinemax_plus` dentro del directorio público de Apache (por ejemplo `htdocs/` en XAMPP).

   > La prueba de Selenium apunta a `http://localhost/CinemaxPlus/`. Renombra la carpeta a `CinemaxPlus` o ajusta la URL en `tests/Browser/LoginSeleniumTest.php`.

2. **Inicia Apache y MySQL** desde el panel de control de XAMPP.

3. **Importa la base de datos**: abre `phpMyAdmin` e importa `cinemax_plus.sql`, o desde la terminal:

   ```bash
   mysql -u root -p < cinemax_plus.sql
   ```

   El script crea las tablas, pero si la base `cinemax_plus` no existe, créala primero:

   ```sql
   CREATE DATABASE cinemax_plus CHARACTER SET utf8mb4;
   ```

4. **Instala las dependencias de PHP**:

   ```bash
   cd cinemax_plus
   composer install
   ```

5. **Abre la aplicación** en el navegador: `http://localhost/CinemaxPlus/home.php`

## Configuración

Las credenciales de la base de datos están en `db.php`:

```php
$host = 'localhost';
$db   = 'cinemax_plus';
$user = 'root';
$pass = '';
```

Ajústalas según tu entorno local.

## Ejecución de las pruebas

Desde la carpeta `cinemax_plus`:

**Pruebas unitarias**

```bash
vendor/bin/phpunit --testsuite Unit
```

Cubren la clase `Cinemax\Auth`:

| Caso | Qué valida |
|---|---|
| `testRegistroDatosValidos` | Acepta correo, contraseña y nombre válidos. |
| `testPasswordCorta` | Rechaza contraseñas de menos de 6 caracteres. |
| `testLimpiarTarjeta` | Elimina los espacios de un número de tarjeta. |

**Pruebas de interfaz (Selenium)**

1. Inicia Selenium Server en el puerto 4444:

   ```bash
   java -jar selenium-server-<version>.jar standalone
   ```

2. Asegúrate de que la aplicación esté corriendo en `http://localhost/CinemaxPlus/`.
3. Ejecuta:

   ```bash
   vendor/bin/phpunit --testsuite Browser
   ```

La prueba abre el login, llena el formulario, hace clic en *Iniciar sesión* y lee la URL resultante.

**Todas las suites**

```bash
vendor/bin/phpunit
```

## Flujo de la aplicación

```
home.php ──► registro.php ──► membresia.php ──┬─► (regular) ──► usuarios.php
   │                                          └─► (premium) ──► pago.php ──► usuarios.php
   └──────► login.php ──────────────────────────────────────────► usuarios.php
                                                                       │
                                                       seleccionar perfil
                                                                       ▼
                                                 repertorio.php ◄──► favoritos.php
```

## Limitaciones conocidas y mejoras de mantenimiento

Este proyecto es académico, y estos puntos son el punto de partida natural para el trabajo de **mantenimiento**:

**Pruebas**
- En `src/Auth.php`, `validarDatosRegistro()` llama a `str_pos()`, que **no existe en PHP** (la función correcta es `strpos()`), y además la condición con `!` está mal planteada. Esto provoca un error fatal en los casos de prueba que llegan a esa línea. La lógica se puede simplificar a un `filter_var($email, FILTER_VALIDATE_EMAIL)`.
- La prueba de Selenium termina con `assertTrue(true)` como marcador de posición; falta una aserción real sobre la URL final o un mensaje de error.
- Se recomienda reemplazar `sleep(2)` por esperas explícitas de WebDriver y preparar datos de prueba controlados en la base.
- Faltan pruebas para registro, perfiles, favoritos y pago.

**Seguridad**
- Las contraseñas se guardan y comparan **en texto plano**. Se debe migrar a `password_hash()` / `password_verify()`.
- No hay protección CSRF en los formularios ni regeneración del ID de sesión tras el login (`session_regenerate_id()`).
- Los mensajes de error exponen `$e->getMessage()` al usuario. Conviene registrarlos en un log y mostrar un mensaje genérico.
- `usuarios.php` elimina perfiles mediante una petición **GET** (`?eliminar=`); debería ser POST con token.
- El pago es una **simulación**: solo valida longitud de tarjeta y CVV, no se conecta a ninguna pasarela ni almacena datos de tarjeta.

**Base de datos y diseño**
- Las tablas usan el motor **MyISAM** sin llaves foráneas ni integridad referencial. Se recomienda **InnoDB** con `FOREIGN KEY` y `ON DELETE CASCADE`.
- La tabla `favs` permite duplicados a nivel de base de datos (solo se evita desde el código). Se puede agregar un índice único `(usuario, id_contenido)`.
- `membresias` guarda el pago premium pero la aplicación no consulta el vencimiento al iniciar sesión.
- La lógica de acceso a datos está mezclada con las vistas en cada archivo PHP; separar en capas (`src/`) facilitaría las pruebas.

## Autor

**Carlos Alejandro Contreras Peña**
Estudiante de Ingeniería de Software, Universidad Tecnológica de Panamá.
