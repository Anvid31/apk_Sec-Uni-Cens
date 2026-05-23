# CaracT Móvil — Referencia Técnica de Implementación

> Documento técnico de arquitectura y construcción de módulos. Flutter · Dart `^3.7.2`

---

## Tabla de Contenidos

1. [Stack y Dependencias](#1-stack-y-dependencias)
2. [Arquitectura de Estado](#2-arquitectura-de-estado)
3. [Sistema de Tema Visual](#3-sistema-de-tema-visual)
4. [Patrón de Navegación Multipaso](#4-patrón-de-navegación-multipaso)
5. [Construcción de Formularios](#5-construcción-de-formularios)
6. [Módulo de Ubicación (GPS)](#6-módulo-de-ubicación-gps)
7. [Módulo de Fotos](#7-módulo-de-fotos)
8. [Módulo de Sincronización y Subida](#8-módulo-de-sincronización-y-subida)
9. [Módulo de Notificaciones](#9-módulo-de-notificaciones)
10. [Patrón de Modelos de Datos](#10-patrón-de-modelos-de-datos)
11. [Configuración de Variables de Entorno](#11-configuración-de-variables-de-entorno)
12. [Módulo Secundario (mismo patrón)](#12-módulo-secundario-mismo-patrón)
13. [Widgets Reutilizables](#13-widgets-reutilizables)
14. [Setup e Inicialización](#14-setup-e-inicialización)

---

## 1. Stack y Dependencias

| Categoría | Paquete | Versión | Uso |
|---|---|---|---|
| Estado | `provider` | `^6.1.1` | `ChangeNotifier` + `MultiProvider` |
| Almacenamiento local | `hive` + `hive_flutter` | `^2.2.3` | Persistencia offline de registros |
| Preferencias | `shared_preferences` | `^2.2.2` | Flags de control y deduplicación |
| Base de datos remota | `mongo_dart` | `^0.10.5` | Inserción directa en MongoDB |
| Email SMTP | `mailer` | `^6.0.1` | Envío directo desde dispositivo |
| Exportación CSV | `csv` | `^5.0.2` | Serialización tabular de datos |
| Compresión | `archive` | `^3.4.10` | Empaquetado ZIP (datos + fotos) |
| GPS | `geolocator` | `^14.0.1` | Posición actual + permisos |
| Cámara/Galería | `image_picker` | `^1.1.2` | Captura y selección de imágenes |
| Notificaciones | `flutter_local_notifications` | `^17.2.4` | Push local con canales Android |
| Conectividad | `connectivity_plus` | `^6.1.5` | Stream de estado de red |
| Archivos | `path_provider` | `^2.1.1` | Directorio temporal del sistema |
| Compartir | `share_plus` | `^10.0.3` | Compartir archivos nativamente |
| Configuración | `flutter_dotenv` | `^5.1.0` | Variables de entorno desde `.env` |

**Plataforma:** Android principal, iOS compatible. Orientación: `portraitUp` forzada en `main()`.

---

## 2. Arquitectura de Estado

### Patrón: Provider + ChangeNotifier

Cada módulo de formulario tiene su propio `ChangeNotifier` registrado globalmente en `main()` mediante `MultiProvider`. No existe estado local en las páginas del formulario — toda mutación ocurre sobre el provider y se propaga via `notifyListeners()`.

```dart
// main.dart
runApp(MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => PrimaryFormState()),
    ChangeNotifierProvider(create: (_) => SecondaryFormState()),
  ],
  child: const MyApp(),
));
```

### Lectura vs escritura en widgets

- **Lectura sin escucha** (`context.read<T>()`) — en callbacks y métodos `onPressed`.
- **Lectura reactiva** (`context.watch<T>()` o `Consumer<T>`) — en widgets que deben reconstruirse.
- Cada `Page` del formulario recibe el estado completo del provider y escribe solo su sub-modelo correspondiente.

### Estructura del estado raíz

Cada `FormState` (ChangeNotifier) agrega sub-modelos independientes:

```
FormState extends ChangeNotifier
├── SubModelA subModelA
├── SubModelB subModelB
├── ...
├── bool isSubmitted
├── DateTime? submissionDate
└── String submissionStatus  // 'pending' | 'sent' | 'error'
```

Cada sub-modelo expone `toJson()` / `fromJson()` para serialización.

---

## 3. Sistema de Tema Visual

### Centralización en `AppTheme` — `lib/config/theme.dart`

Todo el tema se define en una clase estática `AppTheme` con colores como constantes y un método `buildTheme()` que retorna un `ThemeData` de Material 3.

```dart
class AppTheme {
  static const Color primaryColor   = Color(0xFF4CAF50);
  static const Color secondaryColor = Color(0xFF2E7D32);
  static const Color accentColor    = Color(0xFF66BB6A);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color errorColor     = Color(0xFFD32F2F);

  static ThemeData buildTheme() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
    // ... overrides por componente
  );
}
```

### Overrides por componente (valores exactos)

| Componente | Propiedad clave | Valor |
|---|---|---|
| `AppBarTheme` | `backgroundColor` | `primaryColor` |
| `AppBarTheme` | `foregroundColor` | `Colors.white` |
| `AppBarTheme` | `elevation` | `0` |
| `AppBarTheme` | `centerTitle` | `true` |
| `ElevatedButtonThemeData` | `shape` | `RoundedRectangleBorder(radius: 12)` |
| `ElevatedButtonThemeData` | `padding` | `H: 24, V: 12` |
| `InputDecorationTheme` | `border` | `OutlineInputBorder(radius: 12)` |
| `InputDecorationTheme` | `focusedBorder` | `OutlineInputBorder(width: 2, color: primary)` |
| `InputDecorationTheme` | `filled` | `true` (blanco) |
| `CardTheme` | `elevation` | `2` |
| `CardTheme` | `shape` | `RoundedRectangleBorder(radius: 12)` |

### Pantalla de selección de módulos (`SelectionPage`)

Construida con `Column` de dos secciones via `Expanded(flex: N)`:

```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppTheme.secondaryColor, AppTheme.primaryColor],
    ),
  ),
  child: Column(children: [
    Expanded(flex: 1, child: /* Header: ícono 80px + título */),
    Expanded(flex: 2, child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: /* Cards de selección de módulo */,
    )),
  ]),
)
```

---

## 4. Patrón de Navegación Multipaso

### Estrategia: push secuencial con `MaterialPageRoute`

No se usa `go_router` ni rutas nombradas. Cada pantalla navega a la siguiente via `Navigator.push`. No hay retorno de datos; el estado vive en el `Provider`.

```dart
// Avanzar al siguiente paso
Navigator.push(context, MaterialPageRoute(builder: (_) => const NextFormPage()));

// Regresar
Navigator.pop(context);
```

### Helper `FormNavigator`

Clase estática que centraliza la lógica de avance/retroceso y valida el `GlobalKey<FormState>` antes de navegar:

```dart
class FormNavigator {
  static void next(BuildContext context, GlobalKey<FormState> formKey, Widget nextPage) {
    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState!.save();
      Navigator.push(context, MaterialPageRoute(builder: (_) => nextPage));
    }
  }

  static void back(BuildContext context) => Navigator.pop(context);
}
```

### Árbol de rutas (dos módulos independientes)

```
SelectionPage (raíz)
├── FormPage1 → FormPage2 → ... → FormPageN → SummaryPage  (Módulo A)
└── FormPage1 → FormPage2 → ... → FormPageM → SummaryPage  (Módulo B)
```

### Barra de progreso

`EnhancedFormContainer` recibe `currentStep` y `totalSteps` y muestra un `LinearProgressIndicator` con valor `currentStep / totalSteps`.

---

## 5. Construcción de Formularios

### Contenedor genérico — `EnhancedFormContainer`

Wrapper `StatelessWidget` que toda pantalla de formulario usa como `Scaffold`:

```dart
EnhancedFormContainer({
  required String title,
  required String subtitle,
  required Widget child,         // Contenido del paso
  required int currentStep,
  required int totalSteps,
  required VoidCallback onNext,
  required VoidCallback onBack,
  IconData? sectionIcon,
  Color? sectionColor,
})
```

Internamente construye:
1. `AppBar` con título y progreso.
2. `LinearProgressIndicator` visible bajo el AppBar.
3. `SingleChildScrollView` con el `child`.
4. Botones fijos en la parte inferior (`Back` / `Next` o `Submit`).

### Patrón de cada FormPage

```dart
class SomeFormPage extends StatefulWidget { ... }

class _SomeFormPageState extends State<SomeFormPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FormState>();
    return EnhancedFormContainer(
      currentStep: N,
      totalSteps: TOTAL,
      onNext: () => FormNavigator.next(context, _formKey, const NextPage()),
      onBack: () => FormNavigator.back(context),
      child: Form(
        key: _formKey,
        child: Column(children: [
          // Widgets de campo usando state para leer/escribir
        ]),
      ),
    );
  }
}
```

### Tipos de campos usados por paso

| Tipo de dato | Widget personalizado | Validación |
|---|---|---|
| Texto libre | `CustomTextField` | `validator` con regex o `isNotEmpty` |
| Fecha | `CustomDateField` | `showDatePicker` + formatter |
| Selección lista fija | `CustomDropdownField` | `validator: requiredValidator` |
| Entero con controles | `CustomNumberField` | min/max bounds |
| Booleano | `Switch` / `CheckboxListTile` | — |
| Coordenadas GPS | `LocationField` | Regex `lat, lon` |
| Foto | `PhotoCaptureField` | Opcional o requerido |
| Lista con sub-items | `ListView.builder` dinámico | Inline por ítem |

### Banner informativo de sección

Cada paso incluye un encabezado visual construido con:

```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(colors: [sectionColor.withOpacity(0.1), Colors.white]),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Row(children: [Icon(sectionIcon), Text(sectionDescription)]),
)
```

### SummaryPage

La última página de cada módulo muestra un resumen de todos los pasos usando `Consumer<FormState>` para leer en modo solo-lectura. Contiene el botón de envío que invoca `FormSubmissionService`.

---

## 6. Módulo de Ubicación (GPS)

### Servicio — `lib/services/location_service.dart`

**Dependencia:** `geolocator: ^14.0.1`

Clase estática sin estado. Todos los métodos son `static Future<>`.

```dart
class LocationService {
  // 1. Verifica servicios habilitados → pide permisos → retorna posición
  static Future<Position?> getCurrentLocation() async { ... }

  // 2. Convierte Position a String serializable "lat, lon"
  static String formatCoordinates(Position position) =>
      '${position.latitude}, ${position.longitude}';

  // 3. Valida que un String tenga formato correcto
  static bool validateCoordinates(String coordinates) {
    final parts = coordinates.split(',');
    // verifica parseo doble y rangos válidos
  }
}
```

### Configuración `LocationSettings`

```dart
const LocationSettings locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 100, // metros mínimos para actualizar
);
final position = await Geolocator.getCurrentPosition(
  locationSettings: locationSettings,
);
```

### Flujo de permisos (implementado en `getCurrentLocation`)

```
isLocationServiceEnabled()
  └── false → lanzar error "GPS deshabilitado"
checkPermission()
  ├── denied → requestPermission()
  │     └── denied → retornar null
  └── deniedForever → retornar null (usuario va a Settings)
  └── granted/whileInUse → obtener posición
```

### Widget `LocationField` — `lib/widgets/form/location_field.dart`

`StatefulWidget` que envuelve un `TextFormField` con un `IconButton` de sufijo:

```dart
LocationField({
  required TextEditingController controller,
  required void Function(String) onLocationObtained,
  String? label,
  bool required = false,
})
```

**Estados internos:**
- `_isLoading` (bool) — muestra `CircularProgressIndicator` en el sufijo mientras espera GPS.
- `_errorMessage` (String?) — muestra error inline bajo el campo.

**Lógica del botón GPS:**
```dart
// onPressed del IconButton:
setState(() => _isLoading = true);
final pos = await LocationService.getCurrentLocation();
setState(() {
  _isLoading = false;
  if (pos != null) {
    controller.text = LocationService.formatCoordinates(pos);
    onLocationObtained(controller.text);
  } else {
    _errorMessage = 'No se pudo obtener ubicación';
  }
});
```

**Fallback manual:** el `TextFormField` es editable directamente.  
**Validación:** `LocationService.validateCoordinates(value)` en el `validator`.

### Dropdown encadenado — `lib/widgets/form/location_dropdown.dart`

`LocationDropdown` es un `DropdownButtonFormField<String>` con estilo consistente. Soporta listas dependientes: al cambiar la selección del primer dropdown se limpia y recarga el segundo via `setState` en la página padre.

```dart
LocationDropdown({
  required String? value,
  required List<String> items,
  required void Function(String?) onChanged,
  required String label,
  String? Function(String?)? validator,
})
```

---

## 7. Módulo de Fotos

### Modelo de rutas locales

El modelo de fotos contiene únicamente `String?` con rutas al sistema de archivos local — no guarda bytes en memoria:

```dart
class PhotoRecordModel {
  String? photo1;  // ruta absoluta al archivo
  String? photo2;
  // ... N campos según categorías del dominio

  Map<String, dynamic> toJson() => { 'photo1': photo1, ... };
}
```

Las rutas son persistidas en Hive. La conversión a bytes/Base64 ocurre solo en el momento del envío.

### Widget `PhotoCaptureField` — `lib/widgets/form/photo_capture_field.dart`

**Dependencia:** `image_picker: ^1.1.2`

```dart
PhotoCaptureField({
  required String label,
  String? imagePath,                         // ruta actual (null = sin foto)
  required void Function(String?) onImageSelected,
  String? hintText,
  bool required = false,
})
```

**Construcción interna:**

```dart
// Si imagePath != null:
Stack(children: [
  Image.file(File(imagePath!), fit: BoxFit.cover),
  Positioned(top: 8, right: 8, child: /* botón eliminar */),
])

// Si imagePath == null:
Column(children: [
  Icon(Icons.add_a_photo, size: 48),
  Text(hintText ?? 'Tomar o seleccionar foto'),
])
```

**Disparo del selector (`_showImageSourceSheet`):**

```dart
void _showImageSourceSheet(BuildContext context) {
  showModalBottomSheet(context: context, builder: (_) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ListTile(
        leading: Icon(Icons.camera_alt),
        title: Text('Cámara'),
        onTap: () async {
          Navigator.pop(context);
          final file = await ImagePicker().pickImage(source: ImageSource.camera);
          if (file != null) onImageSelected(file.path);
        },
      ),
      ListTile(
        leading: Icon(Icons.photo_library),
        title: Text('Galería'),
        onTap: () async {
          Navigator.pop(context);
          final file = await ImagePicker().pickImage(source: ImageSource.gallery);
          if (file != null) onImageSelected(file.path);
        },
      ),
      if (imagePath != null) ListTile(
        leading: Icon(Icons.delete, color: Colors.red),
        title: Text('Eliminar'),
        onTap: () { Navigator.pop(context); onImageSelected(null); },
      ),
    ],
  ));
}
```

### Persistencia local de fotos

Las rutas se guardan en Hive mediante `StorageService`:

```dart
// Guardar
await StorageService.savePhotoRecord(photoRecordModel);

// Recuperar al reanudar
final saved = await StorageService.loadPhotoRecord();
```

El archivo de imagen en sí permanece en el directorio de la app (`getApplicationDocumentsDirectory()`).

### Conversión a Base64 para envío remoto

`MongoService` y `ZipExportService` procesan las rutas antes de enviar:

```dart
// En MongoService antes de insertar
static Future<Map<String, dynamic>> _processImages(Map<String, dynamic> data) async {
  for (final key in data.keys) {
    final val = data[key];
    if (val is String && File(val).existsSync()) {
      final bytes = await File(val).readAsBytes();
      data[key] = base64Encode(bytes);
    }
  }
  return data;
}
```

En el ZIP, los archivos se copian como bytes sin conversión:

```dart
archive.addFile(ArchiveFile('fotos/foto_$i.$ext', bytes.length, bytes));
```

---

## 8. Módulo de Sincronización y Subida

### Flujo completo de envío

```
SummaryPage (UI)
  └── FormSubmissionService.submit()
        ├── Muestra ProgressDialog
        ├── Construye JSON: { id, timestamp, status, data, metadata }
        └── AutoSyncService.scheduleImmediateSync(json)
              ├── Guarda en SharedPreferences (cola persistente)
              ├── Verifica conectividad
              │   ├── Con internet → _processPendingSurveys()
              │   │     ├── MongoService.saveSurvey()
              │   │     ├── ZipExportService.createZipFile()
              │   │     │     ├── CsvExportService.createCsvFile()
              │   │     │     └── Agrega fotos como bytes al ArchiveFile
              │   │     └── EmailService.sendEmail(zip)
              │   └── Sin internet → encola, reintenta al recuperar red
              └── Dispara NotificationService según resultado
```

---

### `AutoSyncService` — `lib/services/auto_sync_service.dart`

Singleton sin WorkManager (compatibilidad máxima con Android).

#### Mecanismos de disparo

| Mecanismo | Implementación | Frecuencia |
|---|---|---|
| Envío manual | `scheduleImmediateSync()` | Al presionar submit |
| Recuperación de red | `Connectivity().onConnectivityChanged.listen(...)` | Al cambiar a WiFi/móvil |
| Timer periódico | `Timer.periodic(Duration(minutes: 10), ...)` | Cada 10 minutos |
| Forzado desde UI | `forceSyncNow()` | Al tocar el widget de estado |

#### Cola persistente en SharedPreferences

```dart
// Serialización de la cola
final List<String> pending = prefs.getStringList(_pendingSurveysKey) ?? [];
pending.add(jsonEncode(surveyData));
await prefs.setStringList(_pendingSurveysKey, pending);
```

#### Anti-deduplicación

```dart
// Clave única por registro (ajustar campos según dominio)
final key = '${day}-${uniqueField1}-${uniqueField2}';
final sent = prefs.getStringList('sent_keys') ?? [];

if (sent.contains(key)) return; // ya fue enviado

// Ventana de protección: 2 horas
final lastSent = prefs.getInt('sent_$key') ?? 0;
if (DateTime.now().millisecondsSinceEpoch - lastSent < 2 * 3600 * 1000) return;
```

#### Estabilización de red

Al detectar cambio a conectado, espera 3 segundos antes de procesar:

```dart
_connectivityStream.listen((result) async {
  if (result != ConnectivityResult.none) {
    await Future.delayed(const Duration(seconds: 3));
    await _processPendingSurveys();
  }
});
```

---

### `ZipExportService` — `lib/services/zip_export_service.dart`

Usa `package:archive` para crear un `Archive` en memoria, luego lo escribe a `getTemporaryDirectory()`:

```dart
final archive = Archive();

// 1. Agrega CSV
final csvBytes = utf8.encode(csvContent);
archive.addFile(ArchiveFile('data.csv', csvBytes.length, csvBytes));

// 2. Agrega fotos
for (int i = 0; i < photoPaths.length; i++) {
  final bytes = await File(photoPaths[i]).readAsBytes();
  final ext = photoPaths[i].split('.').last;
  archive.addFile(ArchiveFile('fotos/foto_${i+1}.$ext', bytes.length, bytes));
}

// 3. Codifica y guarda
final zipBytes = ZipEncoder().encode(archive)!;
final tempDir = await getTemporaryDirectory();
final zipFile = File('${tempDir.path}/record_${timestamp}.zip');
await zipFile.writeAsBytes(zipBytes);
return zipFile.path;
```

---

### `CsvExportService` — `lib/services/csv_export_service.dart`

Usa `package:csv` (`ListToCsvConverter`). Estructura de tres columnas: `Campo | Valor | Sección`.

```dart
final rows = <List<dynamic>>[
  ['Campo', 'Valor', 'Sección'], // header
  ...sectionRows,               // una fila por dato del formulario
];
return const ListToCsvConverter().convert(rows);
```

---

### `EmailService` — `lib/services/email_service.dart`

**Estrategia dual STARTTLS → SSL:**

```dart
Future<bool> sendEmail(String zipPath) async {
  final smtpServer = _resolveSmtpServer(senderEmail); // detecta dominio
  
  try {
    // Intento 1: STARTTLS puerto 587
    final server587 = SmtpServer(smtpServer, port: 587,
      username: senderEmail, password: senderPassword, ssl: false);
    await send(message, server587);
    return true;
  } catch (_) {
    try {
      // Intento 2: SSL directo puerto 465
      final server465 = SmtpServer(smtpServer, port: 465,
        username: senderEmail, password: senderPassword, ssl: true);
      await send(message, server465);
      return true;
    } catch (e) {
      return false;
    }
  }
}

String _resolveSmtpServer(String email) {
  final domain = email.split('@').last;
  return switch (domain) {
    'gmail.com'                        => 'smtp.gmail.com',
    'outlook.com' || 'hotmail.com'     => 'smtp-mail.outlook.com',
    _                                  => dotenv.env['SMTP_HOST'] ?? 'smtp.$domain',
  };
}
```

**Construcción del mensaje:**

```dart
final message = Message()
  ..from = Address(senderEmail, senderName)
  ..recipients.add(destinationEmail)
  ..subject = buildSubject(formData)
  ..text = buildBody(formData)
  ..attachments.add(FileAttachment(File(zipPath)));
```

---

### `MongoService` — `lib/services/mongo_service.dart`

Conexión lazy: se abre al primer `saveSurvey()` y se mantiene abierta.

```dart
Db? _db;

Future<void> connect() async {
  _db ??= await Db.create(dotenv.env['MONGO_CONN_URL']!);
  if (_db!.state == State.CLOSED) await _db!.open();
}

Future<void> saveSurvey(Map<String, dynamic> data) async {
  await connect();
  final processedData = await _processImages(data); // Base64
  processedData['fechaSubida'] = DateTime.now().toIso8601String();
  
  // Detecta colección por campo de tipo en el JSON
  final collection = data['formType'] == 'secondary'
      ? _db!.collection('secondary_collection')
      : _db!.collection('primary_collection');
  
  await collection.insert(processedData);
}
```

---

### `StorageService` — `lib/services/storage_service.dart`

Abstracción sobre Hive. Inicializado en `main()` antes de `runApp()`.

```dart
class StorageService {
  static late Box _primaryBox;
  static late Box _secondaryBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    _primaryBox = await Hive.openBox('primary_box');
    _secondaryBox = await Hive.openBox('secondary_box');
  }

  // Guarda registro con ID generado por timestamp
  static Future<String> saveRecord(Map<String, dynamic> data) async {
    final id = DateTime.now().toIso8601String();
    await _primaryBox.put(id, { ...data, 'syncStatus': 'pending' });
    return id;
  }

  // Actualiza estado de sincronización
  static Future<void> markAsSynced(String id) async {
    final record = _primaryBox.get(id);
    await _primaryBox.put(id, { ...record, 'syncStatus': 'synced' });
  }

  // Recupera todos los pendientes
  static List<Map> getPendingRecords() =>
    _primaryBox.values
      .where((v) => v['syncStatus'] == 'pending')
      .cast<Map>()
      .toList();
}
```

---

### Widgets de estado de sincronización

#### `SyncStatusWidget` — `lib/widgets/sync_status_widget.dart`

`StatefulWidget` que:
- Suscribe a `Connectivity().onConnectivityChanged` en `initState`.
- Mantiene timer `Timer.periodic(Duration(seconds: 30), ...)`.
- Llama `AutoSyncService.forceSyncNow()` cuando `hasConnectivity && pendingCount > 0`.
- Muestra `SnackBar` con `ScaffoldMessenger` durante sincronización activa.

#### `AutoSyncStatusWidget` — `lib/widgets/auto_sync_status_widget.dart`

Versión compacta para incrustar en la `SummaryPage`:
- `Timer.periodic(Duration(seconds: 2), ...)` para polling ligero.
- Muestra: ícono de red + contador de pendientes.
- Cancela timer en `dispose()`.

---

## 9. Módulo de Notificaciones

### `NotificationService` — `lib/services/notification_service.dart`

**Dependencia:** `flutter_local_notifications: ^17.2.4`

Singleton con guard `_isInitialized` para evitar doble inicialización.

### Inicialización

```dart
static Future<void> initialize() async {
  if (_isInitialized) return;

  const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
  const iosInit = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  await _plugin.initialize(
    const InitializationSettings(android: androidInit, iOS: iosInit),
    onDidReceiveNotificationResponse: _onNotificationTapped,
  );

  // Crear canales Android
  await _createChannels();
  _isInitialized = true;
}
```

### Creación de canales Android

Cada canal se crea una sola vez en `initialize()`. El patrón por canal:

```dart
await _plugin
  .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
  ?.createNotificationChannel(AndroidNotificationChannel(
    channelId,     // ID único
    channelName,   // Nombre visible
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  ));
```

Los tres canales definidos siguen este patrón:

| Propósito | Importancia | Color accent |
|---|---|---|
| Envío exitoso | `Importance.high` | Verde (`0xFF4CAF50`) |
| Envío programado/offline | `Importance.defaultImportance` | Azul (`0xFF2196F3`) |
| Error de envío | `Importance.high` | Rojo (`0xFFF44336`) |

### Método genérico de notificación

```dart
static Future<void> _show({
  required int id,
  required String channelId,
  required String channelName,
  required String title,
  required String body,
  required Color color,
  required String payload,
}) async {
  await _plugin.show(id, title, body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channelId, channelName,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
        color: color,
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(body),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    payload: payload,
  );
}
```

### Acción al tocar (`_onNotificationTapped`)

```dart
static void _onNotificationTapped(NotificationResponse response) {
  // Diseño deliberado: solo dismissea, no navega
  // El payload puede usarse para navegación futura
  _plugin.cancel(response.id ?? 0);
}
```

### Invocación desde `AutoSyncService`

```dart
// Éxito
await NotificationService.showFormSubmittedNotification(recordIdentifier);

// Sin conexión, encolado
await NotificationService.showFormScheduledNotification(recordIdentifier);

// Error
await NotificationService.showFormErrorNotification(errorMessage);
```

---

## 10. Patrón de Modelos de Datos

### Estructura de un sub-modelo

Cada sección del formulario tiene su propia clase modelo con:

```dart
class SectionModel {
  // Campos tipados (String, bool, int, double, List<T>, DateTime)
  String field1;
  bool field2;
  int field3;

  SectionModel({
    this.field1 = '',
    this.field2 = false,
    this.field3 = 0,
  });

  // Serialización para Hive / MongoDB / SharedPreferences
  Map<String, dynamic> toJson() => {
    'field1': field1,
    'field2': field2,
    'field3': field3,
  };

  factory SectionModel.fromJson(Map<String, dynamic> json) => SectionModel(
    field1: json['field1'] as String? ?? '',
    field2: json['field2'] as bool? ?? false,
    field3: json['field3'] as int? ?? 0,
  );

  // Reset para nueva encuesta
  void reset() {
    field1 = '';
    field2 = false;
    field3 = 0;
  }
}
```

### `FormState` (ChangeNotifier raíz)

```dart
class FormState extends ChangeNotifier {
  SectionModel sectionA = SectionModel();
  SectionModel sectionB = SectionModel();
  // ...

  bool isSubmitted = false;
  DateTime? submissionDate;
  String submissionStatus = 'pending'; // 'pending' | 'sent' | 'error'
  String? errorMessage;

  void updateSectionA(SectionModel value) {
    sectionA = value;
    notifyListeners();
  }

  Map<String, dynamic> toJson() => {
    'sectionA': sectionA.toJson(),
    'sectionB': sectionB.toJson(),
    // ...
  };

  void resetAll() {
    sectionA = SectionModel();
    sectionB = SectionModel();
    isSubmitted = false;
    submissionStatus = 'pending';
    notifyListeners();
  }
}
```

### JSON enviado a MongoDB / AutoSync

```json
{
  "id": "<timestamp_ms>",
  "timestamp": "<ISO8601>",
  "status": "completed",
  "data": { /* FormState.toJson() */ },
  "metadata": {
    "appVersion": "x.y.z",
    "deviceInfo": "...",
    "submissionTime": "<ISO8601>"
  }
}
```

### Modelo con sub-items (patrón lista dinámica)

Para secciones con listas de ítems variables:

```dart
class ListItem {
  String name;
  int quantity;
  bool isActive;
  // ...
}

class ListSectionModel {
  List<ListItem> items;
  String otherDescription; // campo libre adicional

  // toJson serializa la lista completa
}
```

---

## 11. Configuración de Variables de Entorno

### Mecanismo: `flutter_dotenv`

El archivo `.env` se declara como asset en `pubspec.yaml` y se carga síncronamente al inicio:

```yaml
# pubspec.yaml
flutter:
  assets:
    - .env
```

```dart
// main.dart — antes de runApp
await dotenv.load(fileName: ".env");
```

### Clase de acceso — `lib/config/app_config.dart`

```dart
class AppConfig {
  static String get senderEmail    => dotenv.env['SENDER_EMAIL'] ?? '';
  static String get senderPassword => dotenv.env['SENDER_PASSWORD'] ?? '';
  static String get senderName     => dotenv.env['SENDER_NAME'] ?? '';
  static String get destinationEmail => dotenv.env['DESTINATION_EMAIL'] ?? '';
  static String get mongoConnUrl   => dotenv.env['MONGO_CONN_URL'] ?? '';

  static bool get isEmailConfigured =>
    senderEmail.isNotEmpty && senderPassword.isNotEmpty && destinationEmail.isNotEmpty;
}
```

### Variables requeridas

```env
SENDER_EMAIL=...        # Cuenta SMTP de envío
SENDER_PASSWORD=...     # Contraseña de aplicación (no la de la cuenta)
SENDER_NAME=...         # Nombre visible en el correo
DESTINATION_EMAIL=...   # Destino de los datos
MONGO_CONN_URL=...      # MongoDB Atlas connection string
```

> **Seguridad:** El archivo `.env` debe estar en `.gitignore`. En producción se puede reemplazar por variables de entorno del sistema de CI/CD.

---

## 12. Módulo Secundario (mismo patrón)

El segundo módulo de la app sigue exactamente los mismos patrones técnicos que el módulo principal. Las diferencias son:

| Aspecto | Módulo Principal | Módulo Secundario |
|---|---|---|
| Número de pasos | 9 | 5 |
| ChangeNotifier | `PrimaryFormState` | `SecondaryFormState` |
| Colección MongoDB | `primary_collection` | `secondary_collection` |
| `formType` en JSON | `'primary'` | `'secondary'` |
| Último paso | `SummaryPage` + envío | `SummaryPage` + envío |

### Patrón de ítem con sub-ítems (usado en módulo secundario)

```dart
class CatalogItem {
  final String id;
  final String category;
  final String type;      // ej: 'PARENT' | 'CHILD' | 'LEAF'
  final String code;
  final String name;
  int quantity;
  String observations;
  List<CatalogSubItem>? subItems;

  // toJson recursivo
  Map<String, dynamic> toJson() => {
    'id': id,
    'quantity': quantity,
    'subItems': subItems?.map((s) => s.toJson()).toList(),
    // ...
  };
}
```

El catálogo de ítems se define como `List<CatalogItem>` en un archivo de datos estático (`lib/data/catalog.dart`), no en una API.

---

## 13. Widgets Reutilizables

### Campos de formulario (`lib/widgets/form/`)

| Widget | Clase base Flutter | Patrón de construcción |
|---|---|---|
| `CustomTextField` | `TextFormField` | Etiqueta + `controller` + `validator` |
| `CustomDateField` | `TextFormField` + `showDatePicker` | Ícono sufijo que abre picker; formatea a `dd/MM/yyyy` |
| `CustomDropdownField` | `DropdownButtonFormField<String>` | Items como `List<String>`, estilo global del tema |
| `CustomNumberField` | `Row` con `IconButton` + `TextField` | Botones `+`/`-` con bounds min/max |
| `LocationField` | `TextFormField` + `IconButton` | Sufijo GPS con estado de carga (ver §6) |
| `LocationDropdown` | `DropdownButtonFormField<String>` | Lista dependiente, callback `onChanged` en padre |
| `PhotoCaptureField` | `GestureDetector` + `Container` | ModalBottomSheet al tocar (ver §7) |
| `AutocompleteField` | `Autocomplete<String>` | Lista de sugerencias filtradas por input |

### Layouts (`lib/widgets/layout/`)

| Widget | Propósito | Props clave |
|---|---|---|
| `FormContainer` | `Scaffold` base con `AppBar` y scroll | `title`, `child`, `onNext`, `onBack` |
| `EnhancedFormContainer` | Versión con progreso y subtítulo | `currentStep`, `totalSteps`, `subtitle`, `sectionIcon` |
| `RoundedContainer` | `Container` decorado reutilizable | `color`, `radius`, `padding`, `shadow` |

### Construcción de `EnhancedFormContainer`

```dart
Scaffold(
  appBar: AppBar(title: Text(title)),
  body: Column(children: [
    LinearProgressIndicator(value: currentStep / totalSteps),
    Expanded(child: SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: child,
    )),
    // Botones fijos en la parte inferior
    SafeArea(child: Padding(
      padding: EdgeInsets.all(16),
      child: Row(children: [
        if (currentStep > 1) OutlinedButton(onPressed: onBack, child: Text('Anterior')),
        Spacer(),
        ElevatedButton(onPressed: onNext,
          child: Text(currentStep == totalSteps ? 'Finalizar' : 'Siguiente')),
      ]),
    )),
  ]),
)
```

---

## 14. Setup e Inicialización

### `main()` completo

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Variables de entorno
  await dotenv.load(fileName: ".env");

  // 2. Almacenamiento local
  await Hive.initFlutter();
  await StorageService.init();

  // 3. Servicios de background
  await AutoSyncService.initialize();
  await NotificationService.initialize();

  // 4. Orientación
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => PrimaryFormState()),
      ChangeNotifierProvider(create: (_) => SecondaryFormState()),
    ],
    child: const MyApp(),
  ));
}
```

### Permisos Android — `AndroidManifest.xml`

```xml
<!-- GPS -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

<!-- Cámara y galería -->
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>

<!-- Red -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>

<!-- Notificaciones locales (Android 13+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### Assets mínimos en `pubspec.yaml`

```yaml
flutter:
  assets:
    - assets/
    - assets/icon/
    - .env
```

### Estructura de carpetas recomendada

```
lib/
├── main.dart
├── config/
│   ├── theme.dart       # AppTheme
│   └── app_config.dart  # Getters de .env
├── models/
│   ├── primary_form_state.dart
│   ├── secondary_form_state.dart
│   └── [section_model].dart  (uno por sección)
├── services/
│   ├── auto_sync_service.dart
│   ├── storage_service.dart
│   ├── mongo_service.dart
│   ├── email_service.dart
│   ├── zip_export_service.dart
│   ├── csv_export_service.dart
│   ├── location_service.dart
│   ├── notification_service.dart
│   └── form_submission_service.dart
├── views/
│   ├── selection_page.dart
│   ├── primary/   (FormPage1..N + SummaryPage)
│   └── secondary/ (FormPage1..M + SummaryPage)
├── widgets/
│   ├── form/      (CustomTextField, PhotoCaptureField, LocationField, ...)
│   ├── layout/    (EnhancedFormContainer, RoundedContainer, ...)
│   └── sync_status_widget.dart
├── data/
│   └── catalog.dart  (datos estáticos de catálogos)
└── utils/
    └── image_helper.dart
```

---

*Referencia técnica — CaracT Móvil.*

