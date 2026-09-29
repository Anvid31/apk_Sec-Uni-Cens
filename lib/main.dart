import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/unified_survey_state.dart';
import 'views/selection_page.dart';
import 'config/theme.dart';
import 'services/storage_service.dart';
import 'services/auto_sync_service.dart';
import 'services/notification_service.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _installGlobalErrorHandlers();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // Sin .env la app sigue: Supabase queda "no configurado" y las
    // encuestas se guardan en la cola local.
    print('❌ No se pudo cargar .env: $e');
  }

  // Inicializar Supabase
  if (SupabaseService.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseService.url,
        anonKey: SupabaseService.anonKey,
      );
      print('✅ Supabase inicializado');
    } catch (e) {
      print('❌ Error inicializando Supabase: $e');
    }
  } else {
    print('⚠️ Supabase no configurado — actualiza SUPABASE_URL y SUPABASE_ANON_KEY en .env');
  }

  try {
    await StorageService.init();
  } catch (e) {
    print('Error al inicializar Hive: $e');
  }

  // Restaurar borrador guardado
  final surveyState = UnifiedSurveyState();
  final draft = StorageService.loadDraft();
  if (draft != null) {
    surveyState.loadFromJson(draft);
    print('✅ Borrador restaurado');
  }

  try {
    await AutoSyncService.initialize();
  } catch (e) {
    print('Error al inicializar sincronización: $e');
  }

  try {
    await NotificationService.initialize();
  } catch (e) {
    print('Error al inicializar notificaciones: $e');
  }

  try {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  } catch (_) {}

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: surveyState),
      ],
      child: const MyApp(),
    ),
  );
}

/// Captura errores no manejados para que no cierren la app.
void _installGlobalErrorHandlers() {
  // Errores de build/layout/render de Flutter.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    print('❌ FlutterError: ${details.exceptionAsString()}\n${details.stack}');
  };

  // Errores asíncronos no capturados (Futures, streams, plugins).
  PlatformDispatcher.instance.onError = (error, stack) {
    print('❌ Error no capturado: $error\n$stack');
    return true; // marcado como manejado: la app no se cierra
  };

  // En release reemplaza la pantalla gris por un mensaje entendible.
  if (kReleaseMode) {
    ErrorWidget.builder = (details) => const Material(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Ocurrió un error al mostrar esta sección. '
                'Sus datos siguen guardados; vuelva atrás e intente de nuevo.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caracterización y Mapeo de Necesidades I.E.',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const _LifecycleWrapper(child: SelectionPage()),
    );
  }
}

/// Guarda el borrador cuando la app pasa a segundo plano.
class _LifecycleWrapper extends StatefulWidget {
  const _LifecycleWrapper({required this.child});
  final Widget child;

  @override
  State<_LifecycleWrapper> createState() => _LifecycleWrapperState();
}

class _LifecycleWrapperState extends State<_LifecycleWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      final survey = context.read<UnifiedSurveyState>();
      StorageService.saveDraft(survey.toJson());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
