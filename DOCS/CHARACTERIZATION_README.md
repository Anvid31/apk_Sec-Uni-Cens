# Documentación: Módulo de Caracterización de Sedes

Esta documentación sigue el marco de trabajo **Diátaxis**, organizando el contenido en Tutoriales, Guías Prácticas, Referencia y Explicación.

---

## 1. Tutoriales (Aprender con la práctica)

### Iniciando una Caracterización de Sede

Este tutorial le guiará a través del flujo básico para completar un diagnóstico de infraestructura escolar.

**Paso 1: Selección del Módulo**

1. Abra la aplicación "CaracT Móvil".
2. En la pantalla de bienvenida, seleccione la tarjeta **"Caracterización de Sedes"**.
3. Se abrirá el formulario principal con múltiples pestañas o pasos.

**Paso 2: Información Institucional**

1. La primera pantalla es "Información General".
2. Ingrese el código DANE o nombre de la sede.
3. El sistema puede intentar autocompletar datos si hay conexión.
4. Complete los campos de contacto del rector/encargado.

**Paso 3: Navegación por Componentes**

1. Utilice la barra de navegación inferior o superior para moverse entre secciones:
   - **Cobertura**: Datos de matrícula y docentes.
   - **Infraestructura**: Estado de aulas, baños, techos.
   - **Servicios**: Energía, Agua, Gas.
   - **Electrodomésticos**: Inventario de equipos eléctricos.

**Paso 4: Captura de Evidencias**

1. Vaya a la sección "Registro Fotográfico".
2. Toque el icono de cámara para capturar fotos de fachada, aulas, etc.
3. Las fotos se etiquetan automáticamente con coordenadas GPS.

**Paso 5: Finalización y Envío**

1. Navegue a la última sección "Observaciones Finales".
2. Revise el resumen de datos.
3. Presione el botón **"Enviar Formulario"**.
4. Seleccione **"Envío Automático"** para garantizar la sincronización segura con la base de datos.
5. El indicador de estado cambiará a verde cuando la sincronización se complete.

---

## 2. Guías Prácticas (Cómo hacer...)

### ¿Cómo registrar la ubicación exacta?

El formulario captura automáticamente la geolocalización al iniciar.

- **Verificar**: En la sección de "Información General", observe los campos de Latitud y Longitud.
- **Actualizar**: Si aparecen en 0.0 o vacíos, asegúrese de tener el GPS activo y los permisos concedidos. Presione el botón de "Actualizar Ubicación" si está disponible.

### ¿Cómo reportar daños críticos en infraestructura?

En la pestaña de **Infraestructura**:

1. Localice el componente afectado (ej. "Techos").
2. Seleccione el estado "Malo" o "Regular".
3. Use el campo de observaciones adjunto para detallar el tipo de daño (goteras, grietas).
4. Tome una foto específica del daño en la sección de "Registro Fotográfico".

### ¿Qué hacer si no tengo internet?

El sistema está diseñado para funcionar "Offline-First".

1. Complete el formulario normalmente.
2. Al finalizar, presione "Enviar" y elija "Envío Automático".
3. El sistema detectará la falta de conexión y guardará los datos localmente (Persistencia Hive).
4. **Puede cerrar la app**. El servicio en segundo plano detectará cuando recupere la conexión (WiFi o Datos) y enviará la información sin intervención suya.

### ¿Cómo corregir un dato antes de enviar?

Puede navegar libremente entre pestañas.

- Simplemente toque la pestaña correspondiente o deslice la pantalla.
- Modifique el campo deseado. El estado se actualiza automáticamente en memoria hasta que decida guardar/enviar.

---

## 3. Referencia (Descripción técnica)

### Modelo de Datos (`SurveyState`)

El estado de la aplicación se gestiona mediante un `ChangeNotifier` central (`SurveyState`) que agrega múltiples objetos de información (`*Info`).

| Clase Modelo             | Descripción                | Campos Clave                                                      |
| ------------------------ | -------------------------- | ----------------------------------------------------------------- |
| `GeneralInfo`            | Metadatos de la encuesta   | Fecha, encuestador, ID dispositivo.                               |
| `InstitutionalInfo`      | Datos de la sede           | Nombre sede, código DANE, datos rector, ubicación GPS.            |
| `CoverageInfo`           | Estadísticas poblacionales | Matrícula (H/M), docentes, grados, jornadas.                      |
| `InfrastructureInfo`     | Estado físico              | Estado paredes, techos, pisos, baños, riesgos.                    |
| `ElectricityInfo`        | Servicios de energía       | Operador, tipo de conexión, estado redes internas, transformador. |
| `AppliancesInfo`         | Inventario eléctrico       | Listado de neveras, TV, computadores, ventiladores.               |
| `AccessRouteInfo`        | Vías de acceso             | Tipo de vía, estado, tiempo de desplazamiento, transporte.        |
| `PhotographicRecordInfo` | Evidencias visuales        | Rutas de archivos locales para Fachada, Aulas, Baños, Servicios.  |
| `ObservationsInfo`       | Cierre                     | Comentarios generales, firma digital (si aplica).                 |

### Estados de Sincronización

El campo `submissionStatus` en `SurveyState` puede tener los siguientes valores:

- `pending`: Datos guardados localmente, esperando red.
- `syncing`: En proceso de transmisión a MongoDB.
- `sent`: Confirmado por el servidor.
- `error`: Falló el último intento, se reintentará.

---

## 4. Explicación (Entendimiento profundo)

### Arquitectura de Persistencia

El módulo utiliza una arquitectura de doble capa para garantizar la integridad de los datos:

1. **Capa Local (Hive):** Una base de datos NoSQL ligera y rápida embebida en el dispositivo. Cada vez que se avanza en el formulario o se pausa, los datos se serializan y guardan aquí. Esto permite recuperar el trabajo si la batería se agota o la app se cierra inesperadamente.
2. **Capa Remota (MongoDB):** La fuente de verdad centralizada. El `AutoSyncService` actúa como puente, leyendo de Hive y escribiendo en MongoDB cuando las condiciones de red son favorables.

### Lógica de Navegación

A diferencia de un formulario lineal estricto, la caracterización permite una navegación no lineal (pestañas o pasos libres). Esto es crucial en trabajo de campo, donde el encuestador puede empezar por el registro fotográfico mientras camina por la sede y luego sentarse a llenar los datos institucionales. El `FormNavigator` gestiona la validación de pasos completados vs. pasos obligatorios antes del envío final.
