# Base de SchoolDefend — Versión 1.0, versión final 1

`schooldefend.sql` crea una base nueva y seis tablas con datos ficticios. **Los tres hashes de contraseña son placeholders**: preparar una copia privada antes de importar, siguiendo [Instalación](../../docs/INSTALACION.md).

No importar si ya existe `schooldefend`. No es una migración ni un script idempotente; el DDL puede persistir aunque falle la carga posterior.

Recuentos iniciales: usuarios 3, ubicaciones 3, dispositivos 5, tickets 5, seguimiento_tickets 9 e incidentes 2. Las cuentas son `admin`, `tecnico` y `profesor`; las contraseñas las elegimos al preparar la copia privada.

El [diccionario vigente](../../docs/BASE_DE_DATOS.md) explica todos los campos y las relaciones. El entorno de desarrollo documentado utiliza MariaDB 10.4.32. La compatibilidad con MySQL independiente no está verificada.
