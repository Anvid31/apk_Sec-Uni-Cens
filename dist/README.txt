CENS Caracterización — Información del APK
==========================================

Versión: 1.0.1
Plataforma: Android 7.0+ (API 24)

CARACTERÍSTICAS
---------------
- Formulario unificado de caracterización (4 fases)
- Sincronización automática con PostgreSQL
- Captura de fotografías y geolocalización GPS
- Exportación Shapefile desde la base de datos
- Cola offline para zonas sin conectividad
- Actualizaciones automáticas vía GitHub Releases

REQUISITOS
----------
- Android 7.0 o superior
- Cámara y GPS habilitados
- Conexión a PostgreSQL (o cola offline hasta recuperar red)
- Archivo .env configurado con credenciales PG_*

INSTALACIÓN
-----------
1. Habilitar "Orígenes desconocidos" en Android
2. Transferir el APK al dispositivo
3. Instalar y conceder permisos de cámara, ubicación y almacenamiento
4. Configurar .env antes de compilar (ver README.md)

NOTAS
-----
- Aplicación privada para uso interno
- Los datos se almacenan en PostgreSQL centralizado
- Sin conexión, los formularios quedan en cola local hasta sincronizar
