import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:caracterizacion_cens/models/unified_survey_state.dart';
import 'package:caracterizacion_cens/services/storage_service.dart';
import 'package:caracterizacion_cens/config/theme.dart';
import 'package:caracterizacion_cens/views/selection_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: '.env');
    await StorageService.init();
  });

  testWidgets('Demo recorrido CENS Caracterización', (tester) async {
    final surveyState = UnifiedSurveyState();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: surveyState,
        child: MaterialApp(
          theme: AppTheme.light,
          debugShowCheckedModeBanner: false,
          home: const SelectionPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // ── PANTALLA INICIO ──────────────────────────────────────────────────────
    await tester.pump(const Duration(seconds: 3));

    // ── FORMULARIO DE CARACTERIZACIÓN ────────────────────────────────────────
    await tester.tap(find.byKey(const ValueKey('tile_formulario')));
    await tester.pumpAndSettle();

    // ── FASE 1: Información General ──────────────────────────────────────────
    final scrollView1 = find.byType(SingleChildScrollView).first;
    await tester.drag(scrollView1, const Offset(0, -600));
    await tester.pumpAndSettle(const Duration(milliseconds: 600));
    await tester.drag(scrollView1, const Offset(0, -600));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.drag(scrollView1, const Offset(0, -600));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.drag(scrollView1, const Offset(0, 2000));
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    surveyState.municipality = 'Cúcuta';
    surveyState.zone = 'Urbano';
    surveyState.principalInstitution = 'CENS Norte de Santander';
    surveyState.schoolName = 'Sede Principal';
    surveyState.daneCode = '54001${DateTime.now().millisecondsSinceEpoch % 100000}';
    surveyState.educationLevels = ['Primaria', 'Secundaria'];
    surveyState.photoFront = 'demo_foto';
    surveyState.photoClassroom1 = 'demo_foto';
    surveyState.photoClassroom2 = 'demo_foto';
    surveyState.photoBathroom = 'demo_foto';
    await tester.pump(const Duration(milliseconds: 300));

    await tester.ensureVisible(find.byKey(const ValueKey('btn_next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('btn_next')));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // ── FASE 2: Dotación ─────────────────────────────────────────────────────
    final scrollView2 = find.byType(SingleChildScrollView).first;
    await tester.drag(scrollView2, const Offset(0, -600));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.drag(scrollView2, const Offset(0, 600));
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    surveyState.tieneGas = false;
    surveyState.tieneInternet = true;
    surveyState.tieneSalones = false;
    surveyState.tieneComedor = false;
    surveyState.tieneCocinaEspacio = false;
    surveyState.tieneSalonReuniones = false;
    surveyState.tieneHabitaciones = false;
    surveyState.tieneOtrosEspacios = false;
    surveyState.dotTieneCocina = false;
    surveyState.dotTieneComedor = false;
    surveyState.dotTieneEmergencia = false;
    await tester.pump(const Duration(milliseconds: 300));
    await tester.ensureVisible(find.byKey(const ValueKey('btn_next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('btn_next')));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // ── FASE 3: Energía ──────────────────────────────────────────────────────
    final scrollView3 = find.byType(SingleChildScrollView).first;
    await tester.drag(scrollView3, const Offset(0, -600));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.drag(scrollView3, const Offset(0, 600));
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    surveyState.tieneEnergiaElectrica = false;
    surveyState.interesSolucionesSolares = true;
    surveyState.cuentaSalonHerramientasTIC = false;
    surveyState.instalacionesElectricasAdecuadas = false;
    // Fase 4 carga sus campos de texto desde el estado al abrir.
    surveyState.tieneTanqueAlmacenamiento = false;
    surveyState.estadoRedAcueducto = 'Regular';
    surveyState.tieneAguaPotable = 'no';
    surveyState.tienePuntosHidratacion = false;
    surveyState.estadoRedDesague = 'Regular';
    surveyState.totalSanitariosOrinales = '4';
    surveyState.sanitariosSeparados = false;
    surveyState.totalSanitariosFuncionan = '3';
    surveyState.instalacionesDiscapacidad = false;
    surveyState.instalacionesPrimeraInfancia = false;
    surveyState.condicionesSanitarios = ['Iluminación'];
    surveyState.gestionDesechos = ['Contenedores de almacenamiento sin diferenciar'];
    surveyState.sistemaLavadoManos = ['Lavamos'];
    surveyState.totalLlavesLavamanos = '2';
    surveyState.frecuenciaInsumos = 'Media, algunos días a la semana';
    surveyState.infoVisualHigiene = false;
    surveyState.tieneComiteASH = false;
    surveyState.actividadesPromocionASH = ['No se realizan'];
    surveyState.riesgosExperimentados = ['No ha experimentado ningún riesgo'];
    await tester.pump(const Duration(milliseconds: 300));
    await tester.ensureVisible(find.byKey(const ValueKey('btn_next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('btn_next')));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // ── FASE 4: Agua & Saneamiento ───────────────────────────────────────────
    final scrollView4 = find.byType(SingleChildScrollView).first;
    await tester.drag(scrollView4, const Offset(0, -600));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.drag(scrollView4, const Offset(0, 600));
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    surveyState.tieneAccesoAgua = false;
    surveyState.dispositivoSaneamiento = 'no_campo_abierto';
    await tester.pump(const Duration(milliseconds: 300));
    await tester.ensureVisible(find.byKey(const ValueKey('btn_next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('btn_next')));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // ── FASE 5: Riesgo ───────────────────────────────────────────────────────
    final scrollView5 = find.byType(SingleChildScrollView).first;
    await tester.drag(scrollView5, const Offset(0, -600));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.drag(scrollView5, const Offset(0, 600));
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    surveyState.r1SuspendioClases = 'no';
    surveyState.r2Amenazas = ['Inundación'];
    surveyState.r3FormasLlegada = ['A pie'];
    await tester.pump(const Duration(milliseconds: 300));
    await tester.ensureVisible(find.byKey(const ValueKey('btn_next')));
    await tester.pumpAndSettle();

    // ── ENVIAR ───────────────────────────────────────────────────────────────
    await tester.tap(find.byKey(const ValueKey('btn_next')));
    await tester.pumpAndSettle(const Duration(seconds: 4));
    await tester.pump(const Duration(seconds: 2));

    // Cerrar diálogo de resultado
    final acceptBtn = find.text('Aceptar');
    if (acceptBtn.evaluate().isNotEmpty) {
      await tester.tap(acceptBtn);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }

    // ── HISTORIAL ────────────────────────────────────────────────────────────
    await tester.tap(find.byKey(const ValueKey('tile_historial')));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 3));
  });
}
