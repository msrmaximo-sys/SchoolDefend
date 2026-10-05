# SchoolDefend — Versión 1.0, versión final 1

## La idea

Hicimos SchoolDefend como un trabajo de la facultad entre Nicolás Silva y Máximo Rodríguez. Es una aplicación web para organizar los equipos tecnológicos de una institución educativa, reportar fallas y dejar por escrito cómo las atendimos.

## El problema que resuelve

Cuando un problema se comunica solo de palabra, podemos perder el diagnóstico, repetir revisiones o no saber quién lo está atendiendo. Reunimos el inventario, los tickets y los incidentes de seguridad para consultar esos antecedentes desde un mismo sistema.

## Qué hace por rol

| Rol implementado | Operaciones |
|---|---|
| Profesor | Crea tickets y consulta únicamente sus propios reportes, novedades y resultados. |
| Técnico | Gestiona dispositivos, atiende todos los tickets, registra y gestiona incidentes y consulta informes. También crea tickets. |
| Administrador | Tiene las funciones del técnico y administra usuarios y ubicaciones, con bajas lógicas y reactivación. |

El rol **directivo no está implementado**. Los incidentes se registran manualmente: no detectamos amenazas ni escaneamos la red. Los informes se guardan como PDF mediante la impresión del navegador.

## Arquitectura y estructura de carpetas

Usamos páginas PHP con procesamiento al comienzo y HTML después. Compartimos conexión, sesión, funciones y presentación mediante `require_once`. El código es procedural: **no declara el namespace `SchoolDefend`**, no tiene framework, ORM ni una API separada.

```text
14SchoolDefend/
├── README.md, CHANGELOG.md, LICENSE, .gitignore
├── docs/                         Arquitectura, datos, permisos, instalación y código
└── SchoolDefend/                 Raíz web de la aplicación
    ├── index.php                 Indicadores y últimos cinco tickets
    ├── login.php, logout.php     Acceso y cierre de sesión
    ├── config.example.php        Plantilla de la conexión
    ├── includes/                 Sesión, funciones y vistas compartidas
    ├── usuarios/, ubicaciones/   Administración
    ├── dispositivos/             Inventario e historial relacionado
    ├── tickets/                  Reportes y seguimiento acumulativo
    ├── incidentes/               Registro manual de seguridad
    ├── informes/                 Consultas imprimibles
    ├── database/                 Esquema con datos ficticios
    └── css/, img/                Estilos y logos locales
```

La documentación técnica está en [Arquitectura](docs/ARQUITECTURA.md), [Base de datos](docs/BASE_DE_DATOS.md), [Roles y permisos](docs/ROLES_Y_PERMISOS.md) y [Guía de lectura del código](docs/GUIA_CODIGO.md).

## Modelo de datos

Tenemos seis tablas InnoDB: `usuarios`, `ubicaciones`, `dispositivos`, `tickets`, `seguimiento_tickets` e `incidentes`. Las claves foráneas usan `ON DELETE RESTRICT`. Conservamos usuarios, ubicaciones y dispositivos mediante baja lógica; finalizamos tickets e incidentes mediante estados.

Un ticket tiene ubicación obligatoria y equipo opcional. Cada novedad del ticket agrega una fila con autor y fecha. La ficha de un equipo reúne sus tickets e incidentes; no existe una auditoría general de todos sus cambios. En incidentes, acciones y conclusión son campos editables hasta el cierre, sin versiones anteriores.

## Tecnologías

PHP, PDO con el controlador MySQL, sesiones PHP, HTML y CSS propio. La aplicación necesita `pdo_mysql` y `mbstring`. Los scripts locales de pruebas HTTP también necesitan cURL. No hay dependencias de Composer ni un proceso de compilación del frontend.

El entorno de desarrollo documentado usa PHP 8.2.12 y MariaDB 10.4.32 en XAMPP. La compatibilidad con un servidor MySQL independiente no está verificada.

## Instalación

1. Preparar PHP con `pdo_mysql` y `mbstring` y un servidor MySQL/MariaDB compatible.
2. Copiar `SchoolDefend/config.example.php` a `SchoolDefend/includes/conexion.php` y completar `TU_HOST_DB`, `TU_USUARIO_DB` y `TU_CONTRASENA_DB`. La aplicación sigue leyendo únicamente `includes/conexion.php`.
3. Preparar una copia privada del SQL y reemplazar los tres placeholders de hash por hashes generados con PHP para contraseñas elegidas localmente.
4. Importar esa copia **solo en una instalación nueva**, donde no exista `schooldefend`. El SQL crea la base y las seis tablas; no es una migración.
5. Desde `SchoolDefend/`, iniciar el servidor local con `php -S 127.0.0.1:8086 -t .` y abrir [el acceso local](http://127.0.0.1:8086/login.php).

Las cuentas ficticias son `admin`, `tecnico` y `profesor`. **No tienen una contraseña publicada utilizable**: los hashes del SQL son placeholders. El detalle del primer acceso, la configuración, los permisos de la base y la resolución de problemas están en [Instalación](docs/INSTALACION.md).

## Autores

Somos **Nicolás Silva y Máximo Rodríguez**. Hicimos el trabajo de a dos para la facultad. Usamos asistencia de IA, reformulamos el material a mano y guiamos el diseño y las decisiones entre los dos. La responsabilidad por lo que presentamos es nuestra.

## Proceso de desarrollo

Organizamos el trabajo por módulos: datos y acceso, administración e inventario, tickets, incidentes e informes. Compartimos la conexión, la sesión y las vistas comunes para mantener un criterio consistente entre las páginas.

Estudiamos el código línea por línea para entender qué hace cada operación, qué controles aplica y cuáles son sus límites. La documentación acompaña ese recorrido con ejemplos del flujo de datos, las relaciones entre tablas y las reglas de cada rol.

## Licencia

Licencia privada. © 2026 Nicolás Silva y Máximo Rodríguez. Todos los derechos reservados. Prohibido usar, copiar, modificar o distribuir sin autorización escrita. Texto completo en [LICENSE](LICENSE).

## Estado

**Versión 1.0, versión final 1.** Aplicación web académica con inventario, soporte técnico y registro manual de incidentes. La instalación requiere completar la conexión y los hashes de las cuentas de muestra.

Quedan fuera: directivo, adjuntos, notificaciones, detección automática, reapertura de casos finalizados, auditoría integral, exportación CSV y generación de PDF desde PHP. Los indicadores son conteos; no calculamos tiempos medios ni gráficos de tendencias. Los flujos y sus límites están explicados en [Arquitectura](docs/ARQUITECTURA.md).
