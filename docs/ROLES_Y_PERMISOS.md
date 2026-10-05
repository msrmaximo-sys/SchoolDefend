# Roles y permisos

Versión 1.0, versión final 1. Implementamos un rol fijo por cuenta, con tres valores admitidos por PHP y por el ENUM de `usuarios`. No existe directivo ni editor de permisos.

| Operación | Profesor | Técnico | Administrador |
|---|:---:|:---:|:---:|
| Iniciar/cerrar sesión | Sí | Sí | Sí |
| Crear ticket | Sí | Sí | Sí |
| Ver tickets propios y su seguimiento | Sí | Sí | Sí |
| Ver y atender tickets ajenos | No | Sí | Sí |
| Elegir prioridad o responsable, agregar novedades | No | Sí | Sí |
| Editar reporte original después de crearlo | No | No | No |
| Reabrir ticket finalizado | No | No | No |
| Administrar inventario y consultar historial de equipo | No | Sí | Sí |
| Registrar/gestionar incidentes | No | Sí | Sí |
| Editar incidente cerrado | No | No | No |
| Informes generales e impresión | No | Sí | Sí |
| Gestionar usuarios y ubicaciones | No | No | Sí |
| Borrar físicamente registros desde la interfaz | No | No | No |

## Dónde se aplica

- `includes/sesion.php`: consulta cuenta activa en cada petición, admite los tres roles, redirige sin sesión y ofrece `exigirRoles()`.
- `usuarios/*.php` y `ubicaciones/*.php`: las páginas de operaciones exigen administrador.
- `dispositivos`, `incidentes`, `informes` y `tickets/editar.php`: las páginas de operaciones exigen administrador o técnico. Los archivos `opciones.php` solo definen listas.
- `index.php`, `tickets/index.php` y `tickets/detalle.php`: restringen las consultas por creador si es profesor. El detalle ajeno responde 404.
- `tickets/insertar.php`: exige sesión; creador, estado y prioridad inicial los decide el servidor.
- `includes/encabezado.php`: muestra navegación según rol, pero la protección real está en las páginas anteriores.

Un técnico puede gestionar cualquier ticket, aunque esté asignado a otro técnico. `id_tecnico` indica responsabilidad operativa; no es una restricción de acceso por propiedad. Lo mismo ocurre con el responsable de un incidente.

## Límites que debemos explicar

El profesor puede elegir una ubicación y un equipo activo al reportar, aunque no tenga acceso al módulo de inventario. Ese selector muestra código y ubicación, no la ficha técnica completa. Puede leer todas las novedades de sus tickets: no debemos escribir ahí información reservada de incidentes.

El administrador no puede darse de baja a sí mismo, quitar al último administrador activo ni desactivar a alguien con responsabilidades pendientes. Una cuenta inactiva conserva sus relaciones históricas pero deja de autenticarse. Reactivarla no recupera asignaciones que se hayan transferido.

Los permisos son de la aplicación. No limitan a quien tenga acceso administrativo directo a la base o a los archivos del servidor. La integridad de las claves foráneas tampoco comprueba roles ni transiciones; esas reglas se validan en PHP.

## Recorrido de comprobación manual

En una base de prueba configurada, crear un ticket como profesor; intentar abrir un ticket de otro creador y una pantalla administrativa; atenderlo como técnico; volver como profesor y leer el resultado. Luego comprobar que el técnico no puede abrir usuarios/ubicaciones y que el administrador sí. Probar además una cuenta inactiva, un POST sin token y un cierre por GET. Estos pasos modifican datos si se confirma un formulario: usar una copia de prueba.
