# Instalación y primer acceso

Versión 1.0, versión final 1. En esta guía explicamos cómo configurar la conexión, preparar la base y acceder al sistema desde una terminal local.

## Preparar el entorno

Necesitamos PHP con PDO MySQL, mbstring y sesiones, y un servidor MySQL/MariaDB con InnoDB y `utf8mb4`. El entorno de desarrollo documentado usa PHP 8.2.12 y MariaDB 10.4.32 en XAMPP. En otra computadora, comprobamos las extensiones y el funcionamiento con el recorrido indicado al final de esta guía.

Podemos comprobar el entorno con `php -v` y `php -m`. El proceso PHP necesita acceso de lectura al proyecto y escritura en su directorio de sesiones. Si usamos phpMyAdmin, también necesitamos el servidor web que lo atiende; el servidor incorporado de PHP basta para la aplicación local.

## Configurar la conexión sin publicarla

Desde la raíz del proyecto, copiar la plantilla:

```powershell
Copy-Item SchoolDefend/config.example.php SchoolDefend/includes/conexion.php
```

Si ya tenemos una conexión personalizada, revisarla antes de sobrescribirla. Completar dentro de la función `getConexion()`:

| Variable | Valor que debemos poner |
|---|---|
| `$servidor` | Host real de la base; para TCP local puede ser `127.0.0.1`. |
| `$nombreBaseDatos` | `schooldefend`, coincidente con el SQL. |
| `$usuarioBaseDatos` | Usuario local de la aplicación. |
| `$contrasenaBaseDatos` | Su contraseña privada. |

**No hay carga automática de `config.example.php` ni de `.env`.** La plantilla contiene la función completa que espera `includes/sesion.php`; se copia al nombre que ya usa el programa. Así mantenemos el flujo original y excluimos la conexión privada con `.gitignore`.

La cuenta de instalación debe poder crear la base y las tablas. La cuenta de la aplicación necesita SELECT, INSERT y UPDATE sobre sus tablas; el código de la aplicación no hace DELETE ni crea esquemas. No necesitamos permisos para eliminar bases ni crear tablas desde la cuenta de la aplicación.

## Preparar las cuentas ficticias

El SQL contiene `admin`, `tecnico` y `profesor`, pero los tres hashes se distribuyen como `TU_HASH_PASSWORD_GENERADO_CON_PHP`. Esa cadena **no es un hash válido ni permite iniciar sesión**.

1. Crear una carpeta privada `SchoolDefend/.local/` si todavía no existe y copiar allí `database/schooldefend.sql` como `instalacion.sql`. Esa carpeta está excluida de Git.
2. Elegir contraseñas locales distintas para las tres cuentas. Para respetar el formulario existente, usar al menos 8 caracteres y no más de 72 bytes UTF-8.
3. Generar un hash por contraseña. Este ejemplo de PowerShell pide la contraseña sin mostrarla; PHP la recibe por entrada estándar, no como argumento del comando:

```powershell
$claveSchoolDefend = Read-Host 'Contraseña de la cuenta de demostración' -AsSecureString
$credencialSchoolDefend = [System.Net.NetworkCredential]::new('', $claveSchoolDefend)
$credencialSchoolDefend.Password | php -r '$p = rtrim(stream_get_contents(STDIN), "\r\n"); echo password_hash($p, PASSWORD_DEFAULT), PHP_EOL;'
Remove-Variable claveSchoolDefend, credencialSchoolDefend
```

4. Sustituir el placeholder de la fila correspondiente por el hash completo, manteniendo las comillas simples del SQL. Repetir para las tres filas. No usar contraseñas con saltos de línea en este procedimiento.
5. Conservar las contraseñas por un medio privado. No pegar contraseñas ni hashes reales en el SQL versionado ni en la plantilla.

El hash es un verificador de contraseña, no una contraseña cifrada reversible. La autenticación usa `password_verify`, por eso no sirve escribir la contraseña directamente en `password_hash`.

## Importar una sola vez

Con una cuenta de instalación, abrir phpMyAdmin al nivel del servidor e importar la copia privada del SQL en UTF-8. El archivo incluye `CREATE DATABASE schooldefend` y `USE schooldefend`; **no crear antes una base con ese nombre**.

Si `schooldefend` ya existe, no importar encima ni borrarla: revisar su contenido. El script no es idempotente, no incluye DROP y no migra bases previas. Si falla la importación, conservar el error y revisar las tablas creadas antes de repetir: el DDL puede persistir aunque una carga posterior falle.

Los recuentos esperados son 3 usuarios, 3 ubicaciones, 5 dispositivos, 5 tickets, 9 seguimientos y 2 incidentes. La cuenta activa del primer acceso será `admin` con la contraseña que elegimos para su hash. Desde Usuarios podemos crear las cuentas de la demostración final.

## Abrir SchoolDefend

Desde `SchoolDefend/`, con la base iniciada y `php` disponible:

```powershell
php -S 127.0.0.1:8086 -t .
```

Abrir [login local](http://127.0.0.1:8086/login.php). La terminal debe permanecer abierta; Ctrl+C detiene el servidor. `127.0.0.1` es loopback, no la IP de una institución. Se conserva para no exponer el servidor a otras máquinas.

El archivo `iniciar-schooldefend.bat` es un lanzador opcional que asume la ruta convencional de XAMPP. No es necesario para esta instalación. El servidor de desarrollo se inicia en loopback para uso local.

Si usamos Apache, apuntar la raíz web a `SchoolDefend/` o ubicar esa carpeta bajo la raíz de documentos. No servir la carpeta superior completa. `.gitignore` controla Git, **no impide que un servidor web entregue archivos**: excluir del despliegue `.local/`, SQL privados y material de desarrollo. La configuración del servidor debe proteger los archivos no públicos.

## Comprobación de la instalación

Ingresar con cada cuenta, crear un ticket de prueba, atenderlo con diagnóstico y solución, consultar el resultado como profesor y abrir un informe. Para guardar el informe usar Ctrl+P, Guardar como PDF y revisar A4 horizontal. No hay generación de PDF desde PHP.

| Síntoma | Revisión |
|---|---|
| 503 al conectar | Servicio de base, host, nombre de base y credenciales de `includes/conexion.php`; revisar el log local sin publicarlo. |
| `could not find driver` | Habilitar `pdo_mysql` en el PHP que ejecuta el servidor. |
| Función `mb_strlen` inexistente | Habilitar `mbstring`. |
| Login rechazado tras importar | Confirmar que se sustituyeron los tres hashes y que se usa la contraseña correspondiente. |
| Formulario vencido | Recargar para obtener el token de la sesión y comprobar cookies. |
| Puerto ocupado | Ver si ya está corriendo la aplicación; usar otra instancia solo con un puerto disponible. |
| Tablas ya existentes al importar | Detener la importación y revisar el estado; no borrar ni repetir a ciegas. |
