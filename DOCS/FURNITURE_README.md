# Documentación: Módulo de Inventario de Mobiliario

Esta documentación sigue el marco de trabajo **Diátaxis**, organizando el contenido en Tutoriales, Guías Prácticas, Referencia y Explicación.

---

## 1. Tutoriales (Aprender con la práctica)

### Realizando un Inventario de Mobiliario

Este tutorial explica cómo documentar los bienes muebles de una sede educativa paso a paso.

**Paso 1: Acceso al Módulo**

1. Desde la pantalla principal de selección, elija la opción inferior morada/azul: **"Inventario de Mobiliario"**.
2. Se iniciará el flujo de trabajo específico para mobiliario.

**Paso 2: Contexto Geográfico (Filtros)**

1. En la primera pantalla, verá filtros de ubicación.
2. Seleccione: **Departamento** -> **Municipio**.
3. Escriba manualmente el nombre del **Corregimiento/Vereda**.
4. Ingrese el nombre de la Sede Educativa específica.

**Paso 3: Diagnóstico de Espacios**

1. Antes de contar sillas, debe reportar _dónde_ están.
2. Indique si la sede tiene:
   - Salones (ingrese cantidad y escriba manualmente el estado).
   - Comedor/Cocina.
   - Habitaciones/Baños.
3. Esto ayuda a calcular la capacidad instalada real vs. el mobiliario existente.

**Paso 4: Conteo Detallado**

1. En la sección de "Inventario Detallado" o "Ítems", verá categorías como:
   - Pupitres (Unipersonales, Bipersonales).
   - Mobiliario Docente (Escritorios, Sillas).
   - Almacenamiento (Estantes, Archivadores).
   - Tableros.
2. Para cada ítem, ingrese la **cantidad total** física encontrada.
3. Utilice el campo de **Observaciones** para describir manualmente el estado (ej. "5 buenos, 2 malos") si es necesario.

**Paso 5: Cierre del Inventario**

1. Revise los totales calculados automáticamente.
2. Tome fotos grupales o panorámicas de los salones para evidenciar la disposición.
3. Envíe el formulario mediante la opción de **"Envío Automático"**.

---

## 2. Guías Prácticas (Cómo hacer...)

### ¿Cómo registrar mobiliario que no está en la lista estándar?

Si encuentra ítems atípicos (ej. mesas de ping-pong usadas como escritorios):

1. Busque la sección "Otros" o utilices el campo de observaciones en la categoría más cercana.
2. Describa el ítem claramente en el campo de texto.
3. Registre la cantidad total y su estado general.

### ¿Qué hago si la sede esta en riesgo de cierre?

El formulario de Mobiliario incluye una validación de apertura.

1. En la sección de "Información General", marque la opción **"Riesgo de Cierre"**.
2. Seleccione el motivo (ej. falta de alumnos, infraestructura colapsada).
3. Puede enviar el formulario con datos básicos sin llenar el inventario detallado.

---

## 3. Referencia (Descripción técnica)

### Modelo de Datos (`FurnitureSurveyState`)

A diferencia de la caracterización que usa submódulos, el `FurnitureSurveyState` es una estructura más plana y directa, optimizada para conteo rápido.

| Grupo de Datos      | Variables Principales                            | Propósito                                                                                |
| ------------------- | ------------------------------------------------ | ---------------------------------------------------------------------------------------- |
| **Ubicación**       | `departamento`, `municipio`, `vereda`            | Geolocalización administrativa de la sede.                                               |
| **Identificación**  | `nombreSedeEducativa`                            | Llave única para cruzar con base de datos oficial.                                       |
| **Infraestructura** | `hasSalones`, `cantidadSalones`, `estadoSalones` | Valida si hay espacio físico para el mobiliario.                                         |
| **Censo Escolar**   | `numAlumnos`, `numDocentes`                      | Base para calcular el índice de **Déficit de Mobiliario** (Alumnos vs. Pupitres Buenos). |
| **Inventario**      | `items` (Lista dinámica)                         | Lista de objetos con cantidad total y observaciones.                                     |
| **Servicios**       | `tieneEnergia`, `fuenteEnergia`                  | Contexto adicional para equipos eléctricos (computadores).                               |

### Estructura de Ítems (`FurnitureItem`)

Cada tipo de mueble se puede abstraer (en lógica de UI) como un objeto con:

- `nombre`: Etiqueta visible (ej. "Pupitre Unipersonal").
- `quantity`: Cantidad total (Entero).
- `observations`: Detalle del estado o comentarios (Texto libre).

---

## 4. Explicación (Entendimiento profundo)

### ¿Por qué un módulo separado?

El inventario de mobiliario y la caracterización de sedes, aunque relacionados, tienen ciclos de actualización y granularidad diferentes.

- **Caracterización:** Se enfoca en el "Continente" (El edificio, los servicios). Es estático y cambia lentamente (años).
- **Inventario:** Se enfoca en el "Contenido" (Las sillas, mesas). Es dinámico, los muebles se mueven entre salones, se dañan o se dan de baja con mayor frecuencia. Separar los módulos permite realizar campañas de inventario rápidas sin obligar al encuestador a re-evaluar toda la infraestructura del edificio.
