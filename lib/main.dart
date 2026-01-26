import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'models/survey_state.dart';
import 'models/furniture_survey_state.dart';
import 'views/selection_page.dart'; // Cambio: Importamos SelectionPage
import 'config/theme.dart';
import 'services/storage_service.dart';
import 'services/auto_sync_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar configuración del archivo .env
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Archivo .env cargado exitosamente');
  } catch (e) {
    print('⚠️ Error al cargar .env: $e - La app funcionará sin configuración de correo');
  }
  
  // Inicialización robusta sin dependencias críticas
  try {
    await StorageService.init();
    print('Hive inicializado exitosamente');
  } catch (e) {
    print('Error al inicializar Hive: $e');
    // No detener la app si falla Storage
  }
  
  try {
    await AutoSyncService.initialize();
    print('Servicio de sincronización automática inicializado');
  } catch (e) {
    print('Error al inicializar sincronización automática: $e');
    // No detener la app si falla AutoSync
  }
  
  try {
    await NotificationService.initialize();
    print('Servicio de notificaciones inicializado');
  } catch (e) {
    print('Error al inicializar notificaciones: $e');
    // No detener la app si fallan las notificaciones
  }
  
  // Configurar orientación preferida
  try {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  } catch (e) {
    print('Error configurando orientación: $e');
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SurveyState()),
        ChangeNotifierProvider(create: (_) => FurnitureSurveyState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CENS App',
      theme: AppTheme.light,
      home: const SelectionPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
