# Guía de lectura del código

Versión 1.0, versión final 1. Leemos primero las instrucciones ejecutables y contrastamos los comentarios con lo que hacen. Recorremos los archivos por bloques, con referencias de línea para relacionar la explicación con el código. Complementa los [flujos completos](ARQUITECTURA.md) y el [diccionario de SQL](BASE_DE_DATOS.md).

## Cómo leer una sentencia

Para cada sentencia explicamos de dónde sale el dato, qué tipo esperamos, qué condición comprobamos, qué cambia y qué ocurre si falla. En una consulta distinguimos estructura fija, valores parametrizados y columnas devueltas. En una salida distinguimos texto escapado, enteros y constantes. En un cierre de bloque seguimos la llave hasta su condición; una línea vacía organiza la lectura y no ejecuta nada.

- `===` compara valor y tipo; `==` permite conversiones. `in_array(..., true)` también exige tipo.
- `??` usa una alternativa si falta el valor o es null; `?:` la usa para cualquier valor evaluado como falso. No son equivalentes.
- `isset` no acepta null como valor presente; `empty` considera vacíos también 0 y cadenas vacías.
- `<?= ... ?>` imprime una expresión. No la escapa automáticamente.
- `if: endif`, `foreach: endforeach` son sintaxis alternativas usadas para mezclar HTML.
- `fetch` obtiene una fila, `fetchColumn` una columna y `fetchAll` el conjunto. Un resultado vacío se debe distinguir de un registro válido.
- `header` y las cookies deben emitirse antes del cuerpo HTML. `exit` evita ejecutar la vista después de redirigir o rechazar.
- `beginTransaction`, `commit` y `rollBack` agrupan escrituras. `FOR UPDATE` conserva bloqueos hasta terminar la transacción, según el motor y su aislamiento.
- Los comentarios actuales usan marcas como `N`, `N2`, `?`, `*` y `!`; no son sintaxis especial de PHP ni garantizan una afirmación correcta.

## Archivos PHP: lectura y puntos de entrada

Las líneas corresponden a la versión 1.0; pueden cambiar si se edita el archivo. Cada rango completo incluye también HTML, comentarios, llaves y líneas vacías.

### `index.php` — Inicio por rol

Archivo: [fuente](../SchoolDefend/index.php), líneas 1–146.

Carga sesión y conexión; identifica profesor. Cuenta sus tickets o los totales generales; agrega el filtro de creador al listado, ordena por fecha e ID y limita a cinco. Prepara etiquetas, incluye encabezado, recorre indicadores y tickets y cierra el HTML.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 84 | `Paso del procesamiento a la vista común` |

### `login.php` — Autenticación

Archivo: [fuente](../SchoolDefend/login.php), líneas 1–136.

Carga sesión; redirige si ya hay usuario; reabre sesión si fue invalidada. Lee exclusivamente cadenas, conserva la contraseña sin trim, valida token y campos. Busca por usuario, verifica hash/activo/rol, regenera ID y guarda id_usuario. Prepara valores escapados; renderiza el formulario sin volver a mostrar la contraseña.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 29 | `Entrada de procesamiento según método HTTP` |
| 97 | `Paso del procesamiento a la vista común` |
| 113 | `Formulario HTML: revisar método y destino` |

### `logout.php` — Cierre de sesión

Archivo: [fuente](../SchoolDefend/logout.php), líneas 1–27.

Carga las funciones comunes; rechaza métodos distintos de POST con Allow y 405. Comprueba CSRF, destruye la sesión y redirige. Cada exit evita continuar después de una respuesta definitiva.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 9 | `Entrada de procesamiento según método HTTP` |

### `includes/conexion.php` — Conexión PDO

Archivo local: `SchoolDefend/includes/conexion.php` (lo creamos desde la [plantilla de conexión](../SchoolDefend/config.example.php)), líneas 1–39.

Declara getConexion. El static comienza null y permite reutilizar el mismo PDO dentro de la petición. Las cuatro asignaciones configuran el DSN y las credenciales. Construye PDO, fija excepciones/fetch asociativo/preparación nativa, establece zona y retorna. El catch registra el error, devuelve 503 y termina. Los valores de conexión se completan en la copia local.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 5 | `function getConexion()` |

### `includes/funciones.php` — Utilidades de entrada y salida

Archivo: [fuente](../SchoolDefend/includes/funciones.php), líneas 1–62.

escapar convierte a cadena y codifica HTML; nombreRol traduce tres valores con alternativa. tokenFormulario genera 32 bytes aleatorios en hexadecimal una vez por sesión; tokenValido comprueba existencia, tipo y hash_equals. textoEntrada acepta cadenas y aplica trim. idEntrada usa FILTER_VALIDATE_INT con mínimo 1 y devuelve null si falla. errorGuardado distingue el código MySQL 1062 del error genérico.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 5 | `function escapar($texto)` |
| 10 | `function nombreRol($rol)` |
| 21 | `function tokenFormulario()` |
| 29 | `function tokenValido()` |
| 40 | `function textoEntrada($datos, $campo, $valorInicial = '')` |
| 49 | `function idEntrada($datos, $campo)` |
| 55 | `function errorGuardado($error, $mensajeDuplicado)` |

### `includes/sesion.php` — Autenticación y autorización compartidas

Archivo: [fuente](../SchoolDefend/includes/sesion.php), líneas 1–82.

Carga dependencias antes de configurar fecha, sesión y cookies; inicia sesión y envía no-store. cerrarSesion borra datos, vence cookie usando sus parámetros y destruye sesión. usuarioActual consulta usuario activo y valida rol. exigirSesion redirige con 302 y exit; exigirRoles rechaza con 403 sin destruir una sesión válida.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 23 | `function cerrarSesion()` |
| 38 | `function usuarioActual()` |
| 63 | `function exigirSesion($rutaLogin = 'login.php')` |
| 76 | `function exigirRoles($usuario, $rolesPermitidos)` |

### `includes/encabezado.php` — Vista común de apertura

Archivo: [fuente](../SchoolDefend/includes/encabezado.php), líneas 1–98.

Resuelve rutaBase por defecto y escapa título/rutas. Lee y consume el mensaje de éxito. Si hay usuario prepara nombre, rol, token de salida y menú permitido. Abre documento HTML, encabezado, cuenta y formulario POST de logout; recorre el menú; abre main y muestra aviso escapado.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 74 | `Formulario HTML: revisar método y destino` |

### `includes/pie.php` — Vista común de cierre

Archivo: [fuente](../SchoolDefend/includes/pie.php), líneas 1–10.

Cierra main, imprime el pie y cierra contenedor, body y html. Depende del encabezado: no es una página independiente.

### `includes/confirmar_baja.php` — Confirmación reutilizable

Archivo: [fuente](../SchoolDefend/includes/confirmar_baja.php), líneas 1–45.

Recibe registro, título, acción, motivo y token del controlador. Elige texto según activo, muestra última baja y error si existen, y envía POST con token/acción. Exige motivo visualmente solo para baja. La validación efectiva ocurre en baja.php.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 28 | `Formulario HTML: revisar método y destino` |

### `dispositivos/index.php` — Listado de inventario

Archivo: [fuente](../SchoolDefend/dispositivos/index.php), líneas 1–143.

Exige rol técnico/administrador. Valida filtros activo/estado e ID de ubicación; arma SELECT con JOIN, filtros parametrizados y orden por código. Consulta ubicaciones para el selector. Renderiza búsqueda, estado, activo y acciones con IDs enteros.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 64 | `Paso del procesamiento a la vista común` |
| 71 | `Formulario HTML: revisar método y destino` |

### `dispositivos/formulario.php` — Alta y edición del equipo

Archivo: [fuente](../SchoolDefend/dispositivos/formulario.php), líneas 1–218.

Distingue edición por presencia de id, consulta o inicia valores vacíos. Define longitudes de campos; en POST lee, normaliza MAC y valida token, código, listas, IP y observaciones. Abre transacción, relee equipo en edición y valida relaciones bloqueadas con excepción histórica para equipo inactivo. INSERT o UPDATE parametrizado; commit y detalle o rollback y mensaje. Incluye relaciones actuales inactivas en selectores para no ocultarlas.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 42 | `Entrada de procesamiento según método HTTP` |
| 76 | `Inicio de transacción` |
| 136 | `Confirmación del guardado` |
| 171 | `Paso del procesamiento a la vista común` |
| 178 | `Formulario HTML: revisar método y destino` |

### `dispositivos/detalle.php` — Ficha e historial relacionado

Archivo: [fuente](../SchoolDefend/dispositivos/detalle.php), líneas 1–128.

Autoriza, busca equipo con ubicación/responsable/autor de baja y responde 404 si falta. Prepara ficha y consulta tickets e incidentes por id_dispositivo. Renderiza datos, última baja y secciones históricas escapadas. No agrega automáticamente incidentes asociados solo mediante ticket.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 72 | `Paso del procesamiento a la vista común` |

### `dispositivos/baja.php` — Baja y reactivación del equipo

Archivo: [fuente](../SchoolDefend/dispositivos/baja.php), líneas 1–105.

Autoriza y busca registro. POST valida token, acción y motivo. En transacción relee con FOR UPDATE; para baja cuenta pendientes; para reactivación verifica ubicación y responsable activos. Actualiza baja completa o solo activo, confirma y redirige. Finalmente prepara variables para confirmar_baja.php.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 21 | `Entrada de procesamiento según método HTTP` |
| 33 | `Inicio de transacción` |
| 83 | `Confirmación del guardado` |
| 103 | `Paso del procesamiento a la vista común` |

### `dispositivos/opciones.php` — Listas de inventario

Archivo: [fuente](../SchoolDefend/dispositivos/opciones.php), líneas 1–17.

Define siete tipos y tres estados técnicos. Las claves coinciden con ENUM de SQL y las etiquetas se muestran al usuario. No hay consultas ni permisos en este archivo de datos estáticos.

### `usuarios/index.php` — Listado de cuentas

Archivo: [fuente](../SchoolDefend/usuarios/index.php), líneas 1–75.

Exige administrador, valida activo, consulta campos visibles sin hash y ordena por nombre e ID. Muestra rol mediante nombreRol y ofrece edición/baja/reactivación.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 28 | `Paso del procesamiento a la vista común` |
| 35 | `Formulario HTML: revisar método y destino` |

### `usuarios/formulario.php` — Alta y edición de cuentas

Archivo: [fuente](../SchoolDefend/usuarios/formulario.php), líneas 1–144.

Exige administrador y distingue alta/edición. POST valida nombres, rol y contraseña. Bloquea todas las cuentas ordenadas, cuenta administradores, protege al último y comprueba pendientes antes de cambiar a profesor. Genera hash solo cuando corresponde; guarda, confirma y redirige. En fallo conserva los campos visibles, nunca la contraseña.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 26 | `Entrada de procesamiento según método HTTP` |
| 42 | `Inicio de transacción` |
| 97 | `Confirmación del guardado` |
| 118 | `Paso del procesamiento a la vista común` |
| 124 | `Formulario HTML: revisar método y destino` |

### `usuarios/baja.php` — Desactivación de cuenta

Archivo: [fuente](../SchoolDefend/usuarios/baja.php), líneas 1–124.

Valida administrador, registro, token, acción y motivo. Bloquea cuentas para revisar administradores actuales. Comprueba responsabilidades pendientes, autobaja y último administrador. Cambia activo y metadatos o reactiva; confirma/retrocede y presenta su propio formulario de confirmación.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 22 | `Entrada de procesamiento según método HTTP` |
| 34 | `Inicio de transacción` |
| 83 | `Confirmación del guardado` |
| 101 | `Paso del procesamiento a la vista común` |
| 112 | `Formulario HTML: revisar método y destino` |

### `ubicaciones/index.php` — Listado de sectores

Archivo: [fuente](../SchoolDefend/ubicaciones/index.php), líneas 1–73.

Exige administrador. Valida filtro activo y consulta sectores ordenados por nombre; renderiza datos y acciones con escape HTML.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 28 | `Paso del procesamiento a la vista común` |
| 35 | `Formulario HTML: revisar método y destino` |

### `ubicaciones/formulario.php` — Alta y edición del sector

Archivo: [fuente](../SchoolDefend/ubicaciones/formulario.php), líneas 1–73.

Carga registro si hay id. POST valida token, nombre y descripción. Ejecuta INSERT o UPDATE preparado; traduce duplicados y redirige al guardar. Una escritura por operación, sin transacción explícita.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 25 | `Entrada de procesamiento según método HTTP` |
| 56 | `Paso del procesamiento a la vista común` |
| 62 | `Formulario HTML: revisar método y destino` |

### `ubicaciones/baja.php` — Baja y reactivación del sector

Archivo: [fuente](../SchoolDefend/ubicaciones/baja.php), líneas 1–89.

Valida registro, POST y CSRF. Bloquea ubicación, comprueba cambio concurrente y cuenta equipos activos/tickets pendientes. Guarda baja o reactivación y usa la vista compartida de confirmación.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 21 | `Entrada de procesamiento según método HTTP` |
| 33 | `Inicio de transacción` |
| 67 | `Confirmación del guardado` |
| 87 | `Paso del procesamiento a la vista común` |

### `tickets/index.php` — Bandeja de soporte

Archivo: [fuente](../SchoolDefend/tickets/index.php), líneas 1–114.

Sesión para todos; filtra por creador para profesor. Valida estado/prioridad y agrega búsqueda de título/descripción con parámetros. JOIN muestra ubicación, creador y técnico opcional; orden descendente de fecha e ID. Renderiza filtros y enlaces al detalle.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 55 | `Paso del procesamiento a la vista común` |
| 60 | `Formulario HTML: revisar método y destino` |

### `tickets/insertar.php` — Reporte de problema

Archivo: [fuente](../SchoolDefend/tickets/insertar.php), líneas 1–118.

Sesión y valores iniciales. POST valida entradas, inicia transacción y comprueba equipo/ubicación activos y coincidentes con bloqueos. Inserta ticket con creador/estado/prioridad del servidor y seguimiento inicial; confirma y redirige. Consulta selectores activos y renderiza el formulario.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 14 | `Entrada de procesamiento según método HTTP` |
| 28 | `Inicio de transacción` |
| 59 | `Confirmación del guardado` |
| 86 | `Paso del procesamiento a la vista común` |
| 93 | `Formulario HTML: revisar método y destino` |

### `tickets/detalle.php` — Detalle autorizado del ticket

Archivo: [fuente](../SchoolDefend/tickets/detalle.php), líneas 1–96.

Carga ticket con JOIN y agrega creador al WHERE para profesor. Si no se encuentra devuelve 404. Consulta seguimiento en orden cronológico e ID; prepara ficha y posibilidad de gestión según rol/estado. Renderiza reporte, diagnóstico, solución, cancelación y novedades.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 59 | `Paso del procesamiento a la vista común` |

### `tickets/editar.php` — Gestión transaccional de soporte

Archivo: [fuente](../SchoolDefend/tickets/editar.php), líneas 1–198.

Autoriza técnico/administrador; rechaza ausente o finalizado. Valida datos del POST, abre transacción y relee ticket bajo bloqueo. Comprueba transición y requisitos del destino; valida responsable activo. Construye texto de cambios reales y novedad, rechaza guardado vacío/excesivo, actualiza ticket e inserta seguimiento juntos. Confirma y redirige o revierte. Consulta responsables y destinos permitidos para el formulario.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 28 | `Entrada de procesamiento según método HTTP` |
| 56 | `Inicio de transacción` |
| 135 | `Confirmación del guardado` |
| 156 | `Paso del procesamiento a la vista común` |
| 163 | `Formulario HTML: revisar método y destino` |

### `tickets/opciones.php` — Estados y máquina de transiciones

Archivo: [fuente](../SchoolDefend/tickets/opciones.php), líneas 1–18.

Define etiquetas de cinco estados, tres prioridades y destinos por estado. Los estados finales tienen arrays vacíos. Los bucles sobre un mismo estado permiten novedades sin transición; no hay regreso a abierto ni reapertura.

### `incidentes/index.php` — Bandeja de seguridad

Archivo: [fuente](../SchoolDefend/incidentes/index.php), líneas 1–80.

Autoriza técnico/administrador, construye consulta por estado permitido y título, ordena por fecha e ID y muestra responsable. No permite acceso al profesor.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 31 | `Paso del procesamiento a la vista común` |
| 36 | `Formulario HTML: revisar método y destino` |

### `incidentes/formulario.php` — Registro y tratamiento manual

Archivo: [fuente](../SchoolDefend/incidentes/formulario.php), líneas 1–232.

Autoriza, distingue alta/edición y bloquea edición de cerrados. Lee reporte y relaciones solo al crear; gestión lee severidad, responsable, acciones, conclusión y estado. Valida listas, longitudes y cierre. En transacción relee estado, valida responsable y relaciones; impide discordancia si ambos equipos están informados. INSERT o UPDATE, fecha de cierre y commit. Renderiza reporte de alta o gestión conservando el original.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 32 | `Entrada de procesamiento según método HTTP` |
| 73 | `Inicio de transacción` |
| 141 | `Confirmación del guardado` |
| 168 | `Paso del procesamiento a la vista común` |
| 174 | `Formulario HTML: revisar método y destino` |

### `incidentes/detalle.php` — Consulta del incidente

Archivo: [fuente](../SchoolDefend/incidentes/detalle.php), líneas 1–63.

Autoriza y une responsable/creador con relaciones opcionales a equipo/ticket. Rechaza ausente; prepara ficha. Muestra gestión solo si no está cerrado y enlace al ticket si existe. Escapa descripción, acciones y conclusión.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 37 | `Paso del procesamiento a la vista común` |

### `incidentes/opciones.php` — Listas de seguridad

Archivo: [fuente](../SchoolDefend/incidentes/opciones.php), líneas 1–10.

Define cinco tipos, tres severidades y tres estados. No contiene matriz explícita de transiciones: las restricciones se programan en formulario.php.

### `informes/index.php` — Listado imprimible

Archivo: [fuente](../SchoolDefend/informes/index.php), líneas 1–206.

Autoriza y elige tipo de una lista cerrada. Prepara columnas/consulta, valida activo para inventario o fechas para tickets/incidentes. Agrega estado válido y parámetros, ejecuta si no hay error y transforma filas a etiquetas. Cuenta filas y renderiza filtros, fecha/autor y tabla imprimible.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 124 | `Paso del procesamiento a la vista común` |
| 128 | `Formulario HTML: revisar método y destino` |
| 137 | `Formulario HTML: revisar método y destino` |

### `config.example.php` — Plantilla completa de conexión

Archivo: [fuente](../SchoolDefend/config.example.php), líneas 1–40.

Replica getConexion con placeholders. Se copia a includes/conexion.php para instalar. No incluir simultáneamente ambos archivos: definen la misma función global. No contiene un cargador ni variables de entorno.

| Línea | Punto para seguir la ejecución |
|---:|---|
| 6 | `function getConexion()` |

## SQL, CSS, inicio local y recursos

- `database/schooldefend.sql`: crea base, codificación y zona horaria; después las seis tablas en orden de dependencias; luego abre transacción, carga cuentas y escenarios, marca un equipo inactivo y confirma. El [diccionario](BASE_DE_DATOS.md) explica cada columna y FK. Los hashes publicados son marcadores deliberados.
- `css/estilos.css`: variables de color en `:root`, reglas globales y contenedor, flex para encabezado, grid para formularios/indicadores/fichas, tablas desplazables, foco visible, estados y mensajes. Las consultas a 650 px adaptan el diseño. `@media print` prepara los informes. El selector `a :hover` tiene un espacio: selecciona un descendiente en hover, no equivale a `a:hover`.
- `iniciar-schooldefend.bat`: guarda ruta de PHP, puerto y carpeta `%~dp0`; verifica el ejecutable, abre el navegador, inicia PHP en loopback y muestra error si falla. La ruta de XAMPP es una suposición local del lanzador, no una dependencia del código PHP.
- `img/logo-escudo.png` y `img/logo-completo.png`: assets locales usados por encabezado e impresión. No contienen funciones ni consultas.

## Precisiones para no repetir errores de comentarios

`static` reutiliza PDO por petición, no entre todos los usuarios. Una consulta preparada no autoriza al usuario. `SameSite=Lax` no elimina todos los ataques CSRF. Ocultar el menú no protege la URL. `password_hash` no cifra para luego descifrar. `RESTRICT` no impide cualquier UPDATE. Tener una transacción no evita por sí solo sobrescribir datos enviados desde un formulario desactualizado. La interfaz no borra novedades, pero un administrador de la base puede modificarla: no hay almacenamiento inmutable.

La autoría del proyecto es compartida. En [Arquitectura](ARQUITECTURA.md) desarrollamos las consecuencias y los límites de las decisiones técnicas que vemos en el código.
