import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/unified_survey_state.dart';
import '../../utils/draft_autosave.dart';
import '../../widgets/form/yes_no_buttons.dart';
import '../../widgets/layout/enhanced_form_container.dart';
import '../../utils/form_navigator.dart';
import 'phase5_riesgo_page.dart';

class Phase4AguaPage extends StatefulWidget {
  const Phase4AguaPage({super.key});

  @override
  State<Phase4AguaPage> createState() => _Phase4AguaPageState();
}

class _Phase4AguaPageState extends State<Phase4AguaPage>
    with DraftAutosave<Phase4AguaPage> {
  @override
  UnifiedSurveyState get draftState => _s;

  @override
  void syncDraftToState() => _saveToState();

  late UnifiedSurveyState _s;
  bool _showErrors = false;

  // text controllers
  final _cantHidratCtrl = TextEditingController();
  final _totalSanitCtrl = TextEditingController();
  final _cantNinasCtrl = TextEditingController();
  final _cantNinosCtrl = TextEditingController();
  final _totalFuncionanCtrl = TextEditingController();
  final _cantDiscapCtrl = TextEditingController();
  final _cantPrimerInfCtrl = TextEditingController();
  final _totalLlavesCtrl = TextEditingController();
  final _otroRiesgoCtrl = TextEditingController();
  final _observacionesCtrl = TextEditingController();

  static const Color _green = Color(0xFF2E7D32);

  // ── opciones estáticas ──────────────────────────────────────

  static const _fuenteOpts = [
    'De acueducto por tubería',
    'De otra fuente por tubería',
    'Carrotanque',
    'De pila pública',
    'De pozo con bomba',
    'De pozo sin bomba, aljibe, jagüey o barreno',
    'Aguas lluvias',
    'Río, quebrada, nacimiento o manantial',
    'Aguatero',
    'Agua embotellada o en bolsa',
    'No sabe',
    'Ninguna fuente alternativa',
    'Prefiere no responder',
  ];

  static const _frecuenciaAgua = [
    '24/7 durante todo el año',
    '24/7 durante algunos meses del año',
    'Durante algunas horas al día',
    'Durante algunas horas por algunos días de la semana',
    'Prefiere no responder',
  ];

  static const _calidadOpts = [
    'Buena, sin olor, color o sabor',
    'Regular, tiene color o sabor',
    'Mala, tiene mal olor, mal color y mal sabor',
    'No sabe',
  ];

  static const _materialOpts = [
    'Plástico',
    'Concreto',
    'Mampostería',
    'Eternit',
    'Otro',
  ];

  static const _capacidadOpts = [
    'Menos de 500 litros',
    '500-1000 litros',
    '1000-2000 litros',
    '2000-5000 litros',
    'Más de 5000 litros',
  ];

  static const _estadoRedOpts = ['Bueno', 'Regular', 'Malo', 'No sabe'];

  static const _tratamientoOpts = [
    'Filtro (vela cerámica, membrana o arcilla)',
    'Sedimentación',
    'Hervido',
    'Cloración',
    'Sistema de tratamiento completo',
    'El agua ya viene potabilizada',
    'No tiene tratamiento',
    'No sabe',
  ];

  static const _dispositivoSanOpts = [
    'Sí',
    'No tiene servicios sanitario, se realiza defecación a campo abierto',
    'No tiene servicio sanitario, pero tiene un lugar gratuito cercano (lo prestan)',
    'No tiene servicio sanitario y tiene que pagar el servicio',
  ];
  static const _dispositivoSanValues = [
    'si',
    'no_campo_abierto',
    'no_gratuito',
    'no_pago',
  ];

  static const _tipoSanOpts = [
    'Inodoro conectado a alcantarillado',
    'Inodoro conectado a pozo séptico',
    'Inodoro sin conexión (Baños portátiles)',
    'Letrina de pozo con losa y plataforma',
    'Letrina improvisada',
    'Letrinas colgantes o inodoro con descarga directa a fuentes de agua (bajamar)',
    'Otro',
  ];

  static const _condSanitariosOpts = [
    'Iluminación',
    'Seguridad interna (cerrojo, pasallaves)',
    'Ventilación',
    'Privacidad',
    'Ninguno de los anteriores',
  ];

  static const _gestionDesechosOpts = [
    'Contenedores de almacenamiento sin diferenciar',
    'Contenedores especiales por colores (blanco, verde y negro)',
    'Incineración/quema',
    'Enterramiento',
    'Recolección por camión o algún vehículo de tracción',
    'Ninguno de los anteriores',
  ];

  static const _lavadoManoOpts = [
    'Lavamos',
    'Lavamanos con pedal',
    'Lavadero',
    'Ponchera',
    'Otro Artesanal',
    'Ninguno',
  ];

  static const _frecuenciaInsumosOpts = [
    'Alta, todo el tiempo (todos los días)',
    'Media, algunos días a la semana',
    'Baja, algunos días al mes',
    'Pocas veces o nunca',
  ];

  static const _capacitacionComiteOpts = [
    'Sí, todas las labores',
    'Algunas labores básicas de mantenimiento',
    'No, ninguna labor',
  ];

  static const _actividadesPromocionOpts = [
    'Prácticas clave de higiene (cuidado dental, higiene corporal, etc.)',
    'Lavado de manos',
    'Gestión digna de la higiene menstrual',
    'Gestión de residuos sólidos',
    'Uso adecuado del agua en el punto de consumo',
    'Correcto uso de las instalaciones sanitarias',
    'Almacenamiento seguro del agua',
    'No se realizan',
  ];

  static const _quienPromocionOpts = [
    'Personal docente, directivos',
    'Los estudiantes',
    'Algún miembro de la comunidad',
    'Alcaldía / Gobernación',
    'Organización de la cooperación internacional',
    'Empresa pública o privada',
  ];

  static const _frecuenciaActOpts = [
    'Semanal',
    'Quincenal',
    'Mensual',
    'Trimestral',
    'Semestral',
    'Anual',
  ];

  static const _riesgosOpts = [
    'Material Explosivo (Minas o Artefactos)',
    'Desastres naturales o variabilidad climática (inundaciones, deslizamientos, avenidas torrenciales, sismos, erosión del suelo, incendios forestales o sequías)',
    'Daños (Robo, saqueo, ataques)',
    'Otro ¿Cuáles?',
    'No ha experimentado ningún riesgo',
  ];

  @override
  void initState() {
    super.initState();
    _s = Provider.of<UnifiedSurveyState>(context, listen: false);
    startDraftAutosave();
    _cantHidratCtrl.text = _s.cantidadPuntosHidratacion ?? '';
    _totalSanitCtrl.text = _s.totalSanitariosOrinales ?? '';
    _cantNinasCtrl.text = _s.cantSanitariosNinas ?? '';
    _cantNinosCtrl.text = _s.cantSanitariosNinos ?? '';
    _totalFuncionanCtrl.text = _s.totalSanitariosFuncionan ?? '';
    _cantDiscapCtrl.text = _s.cantInstalacionesDiscapacidad ?? '';
    _cantPrimerInfCtrl.text = _s.cantInstalacionesPrimeraInfancia ?? '';
    _totalLlavesCtrl.text = _s.totalLlavesLavamanos ?? '';
    _otroRiesgoCtrl.text = _s.otroRiesgo ?? '';
    _observacionesCtrl.text = _s.observacionesASH ?? '';
  }

  @override
  void dispose() {
    for (final c in [
      _cantHidratCtrl, _totalSanitCtrl, _cantNinasCtrl, _cantNinosCtrl,
      _totalFuncionanCtrl, _cantDiscapCtrl, _cantPrimerInfCtrl,
      _totalLlavesCtrl, _otroRiesgoCtrl, _observacionesCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _saveToState() {
    _s.cantidadPuntosHidratacion = _cantHidratCtrl.text.trim().isNotEmpty ? _cantHidratCtrl.text.trim() : null;
    _s.totalSanitariosOrinales = _totalSanitCtrl.text.trim().isNotEmpty ? _totalSanitCtrl.text.trim() : null;
    _s.cantSanitariosNinas = _cantNinasCtrl.text.trim().isNotEmpty ? _cantNinasCtrl.text.trim() : null;
    _s.cantSanitariosNinos = _cantNinosCtrl.text.trim().isNotEmpty ? _cantNinosCtrl.text.trim() : null;
    _s.totalSanitariosFuncionan = _totalFuncionanCtrl.text.trim().isNotEmpty ? _totalFuncionanCtrl.text.trim() : null;
    _s.cantInstalacionesDiscapacidad = _cantDiscapCtrl.text.trim().isNotEmpty ? _cantDiscapCtrl.text.trim() : null;
    _s.cantInstalacionesPrimeraInfancia = _cantPrimerInfCtrl.text.trim().isNotEmpty ? _cantPrimerInfCtrl.text.trim() : null;
    _s.totalLlavesLavamanos = _totalLlavesCtrl.text.trim().isNotEmpty ? _totalLlavesCtrl.text.trim() : null;
    _s.otroRiesgo = _otroRiesgoCtrl.text.trim().isNotEmpty ? _otroRiesgoCtrl.text.trim() : null;
    _s.observacionesASH = _observacionesCtrl.text.trim().isNotEmpty ? _observacionesCtrl.text.trim() : null;
  }

  void _onNext() {
    _saveToState();

    final missing = [
      for (final e in _required.entries)
        if (e.value) e.key,
    ];

    if (missing.isNotEmpty) {
      setState(() => _showErrors = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Complete los campos requeridos: ${missing.take(4).join(', ')}'
            '${missing.length > 4 ? ' y ${missing.length - 4} más' : ''}',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _s.notify();
    FormNavigator.pushForm(context, const Phase5RiesgoPage(), stepNumber: 5);
  }

  bool _empty(TextEditingController c) => c.text.trim().isEmpty;

  bool get _hayActividadesPromocion =>
      _s.actividadesPromocionASH.isNotEmpty &&
      !_s.actividadesPromocionASH.contains('No se realizan');

  /// Pregunta obligatoria → falta respuesta. Solo incluye las visibles.
  Map<String, bool> get _required => {
        '¿Tiene acceso a agua?': _s.tieneAccesoAgua == null,
        if (_s.tieneAccesoAgua == true) ...{
          'Fuente de abastecimiento': _s.fuenteAbastecimiento.isEmpty,
          'Frecuencia del agua': _s.frecuenciaAgua == null,
          'Calidad del agua': _s.calidadAgua == null,
        },
        'Tanque de almacenamiento': _s.tieneTanqueAlmacenamiento == null,
        if (_s.tieneTanqueAlmacenamiento == true) ...{
          'Material de tanques': _s.materialTanques.isEmpty,
          'Capacidad de tanques': _s.capacidadTanques == null,
        },
        'Estado red de acueducto': _s.estadoRedAcueducto == null,
        'Agua potable': _s.tieneAguaPotable == null,
        if (_s.tieneAguaPotable == 'si')
          'Tratamiento del agua': _s.tratamientoAgua.isEmpty,
        'Puntos de hidratación': _s.tienePuntosHidratacion == null,
        if (_s.tienePuntosHidratacion == true)
          'Cantidad de puntos de hidratación': _empty(_cantHidratCtrl),
        'Dispositivo de saneamiento': _s.dispositivoSaneamiento == null,
        if (_s.dispositivoSaneamiento == 'si')
          'Tipo de saneamiento': _s.tipoSistSaneamiento.isEmpty,
        'Estado red de desagüe': _s.estadoRedDesague == null,
        'Total sanitarios y orinales': _empty(_totalSanitCtrl),
        'Sanitarios separados': _s.sanitariosSeparados == null,
        if (_s.sanitariosSeparados == true) ...{
          'Sanitarios para niñas': _empty(_cantNinasCtrl),
          'Sanitarios para niños': _empty(_cantNinosCtrl),
        },
        'Sanitarios que funcionan': _empty(_totalFuncionanCtrl),
        'Instalaciones para discapacidad': _s.instalacionesDiscapacidad == null,
        if (_s.instalacionesDiscapacidad == true)
          'Cantidad instalaciones discapacidad': _empty(_cantDiscapCtrl),
        'Instalaciones primera infancia': _s.instalacionesPrimeraInfancia == null,
        if (_s.instalacionesPrimeraInfancia == true)
          'Cantidad instalaciones primera infancia': _empty(_cantPrimerInfCtrl),
        'Condiciones de sanitarios': _s.condicionesSanitarios.isEmpty,
        'Gestión de desechos': _s.gestionDesechos.isEmpty,
        'Lavado de manos': _s.sistemaLavadoManos.isEmpty,
        'Llaves y lavamanos funcionales': _empty(_totalLlavesCtrl),
        'Frecuencia de insumos': _s.frecuenciaInsumos == null,
        'Información visual de higiene': _s.infoVisualHigiene == null,
        'Comité ASH': _s.tieneComiteASH == null,
        if (_s.tieneComiteASH == true)
          'Capacitación del comité': _s.capacitacionComite == null,
        'Actividades de promoción': _s.actividadesPromocionASH.isEmpty,
        if (_hayActividadesPromocion) ...{
          'Quién realiza la promoción': _s.quienPromocionASH.isEmpty,
          'Frecuencia de actividades': _s.frecuenciaActividadesASH == null,
        },
        'Riesgos experimentados': _s.riesgosExperimentados.isEmpty,
        if (_s.riesgosExperimentados.contains('Otro ¿Cuáles?'))
          'Otro riesgo': _empty(_otroRiesgoCtrl),
      };

  /// Error inline bajo la pregunta [key] de [_required].
  Widget _err(String key) => _showErrors && (_required[key] ?? false)
      ? _fieldError()
      : const SizedBox.shrink();

  Widget _fieldError([String msg = 'Campo requerido']) => Padding(
    padding: const EdgeInsets.only(left: 12, top: 2, bottom: 4),
    child: Text(msg, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
  );

  @override
  Widget build(BuildContext context) {
    return EnhancedFormContainer(
      title: 'Agua, Saneamiento e Higiene',
      subtitle: 'Si tiene hogar juvenil, considérelo en las respuestas',
      currentStep: 4,
      totalSteps: 5,
      isLastStep: false,
      showPrevious: true,
      isLoading: false,
      onPrevious: () => FormNavigator.popForm(context),
      onNext: _onNext,
      nextLabel: 'Continuar',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══════════════════════════════════════════════════
          //  AGUA
          // ═══════════════════════════════════════════════════
          const _SectionHeader('AGUA'),
          const SizedBox(height: 12),

          _buildYesNo('¿El establecimiento educativo tiene acceso a agua? *',
              _s.tieneAccesoAgua,
              (v) => setState(() => _s.tieneAccesoAgua = v)),
          if (_showErrors && _s.tieneAccesoAgua == null) _fieldError(),

          if (_s.tieneAccesoAgua == true) ...[
            const SizedBox(height: 14),
            _buildMultiCheck(
              '¿Cuál es la fuente de abastecimiento de la sede? (máx. 2) *',
              _fuenteOpts, _s.fuenteAbastecimiento, maxSelect: 2,
              onChanged: (v) => setState(() => _s.fuenteAbastecimiento = v),
            ),
            _err('Fuente de abastecimiento'),
            const SizedBox(height: 14),
            _buildSingleSelect('¿Con qué frecuencia llega el agua a la sede? *',
                _frecuenciaAgua, _s.frecuenciaAgua,
                (v) => setState(() => _s.frecuenciaAgua = v)),
            _err('Frecuencia del agua'),
            const SizedBox(height: 14),
            _buildSingleSelect(
                '¿Cómo describe la calidad del agua que llega? *',
                _calidadOpts, _s.calidadAgua,
                (v) => setState(() => _s.calidadAgua = v)),
            _err('Calidad del agua'),
          ],

          const SizedBox(height: 14),
          _buildYesNo('¿Cuenta con tanque de almacenamiento de agua? *',
              _s.tieneTanqueAlmacenamiento,
              (v) => setState(() => _s.tieneTanqueAlmacenamiento = v)),
          _err('Tanque de almacenamiento'),

          if (_s.tieneTanqueAlmacenamiento == true) ...[
            const SizedBox(height: 14),
            _buildMultiCheck(
                '¿De qué material están hechos los tanques de almacenamiento de agua? *',
                _materialOpts, _s.materialTanques,
                onChanged: (v) => setState(() => _s.materialTanques = v)),
            _err('Material de tanques'),
            const SizedBox(height: 14),
            _buildSingleSelect(
                '¿Cuál es la capacidad de almacenamiento aproximada de todos los tanques de agua en la sede? *',
                _capacidadOpts, _s.capacidadTanques,
                (v) => setState(() => _s.capacidadTanques = v)),
            _err('Capacidad de tanques'),
          ],

          const SizedBox(height: 14),
          _buildSingleSelect(
              '¿Cuál es el estado de la red de Acueducto (Red de tuberías de Distribución) al interior de la sede? *',
              _estadoRedOpts, _s.estadoRedAcueducto,
              (v) => setState(() => _s.estadoRedAcueducto = v)),
          _err('Estado red de acueducto'),

          const SizedBox(height: 14),
          _buildTriState(
            '¿Cuenta con agua potable para consumo humano? *',
            opts: const ['Sí', 'No', 'No sabe'],
            values: const ['si', 'no', 'no_sabe'],
            value: _s.tieneAguaPotable,
            onChanged: (v) => setState(() => _s.tieneAguaPotable = v),
          ),
          _err('Agua potable'),

          if (_s.tieneAguaPotable == 'si') ...[
            const SizedBox(height: 14),
            _buildMultiCheck(
                '¿Cuál es el método usado para el tratamiento del agua? *',
                _tratamientoOpts, _s.tratamientoAgua,
                onChanged: (v) => setState(() => _s.tratamientoAgua = v)),
            _err('Tratamiento del agua'),
          ],

          const SizedBox(height: 14),
          _buildYesNo(
              '¿Existen puntos de hidratación en el establecimiento? *',
              _s.tienePuntosHidratacion,
              (v) => setState(() => _s.tienePuntosHidratacion = v)),
          _err('Puntos de hidratación'),

          if (_s.tienePuntosHidratacion == true) ...[
            const SizedBox(height: 10),
            _numField('¿Cuántos puntos de hidratación? *', _cantHidratCtrl),
            _err('Cantidad de puntos de hidratación'),
          ],

          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════
          //  SANEAMIENTO
          // ═══════════════════════════════════════════════════
          const _SectionHeader('SANEAMIENTO'),
          const SizedBox(height: 12),

          _buildRadioList(
            '¿El establecimiento cuenta con algún dispositivo de saneamiento para la población estudiantil? *',
            _dispositivoSanOpts, _dispositivoSanValues,
            _s.dispositivoSaneamiento,
            (v) => setState(() => _s.dispositivoSaneamiento = v),
          ),
          if (_showErrors && _s.dispositivoSaneamiento == null) _fieldError(),

          if (_s.dispositivoSaneamiento == 'si') ...[
            const SizedBox(height: 14),
            _buildMultiCheck('¿Qué tipo de sistema de saneamiento tiene? *',
                _tipoSanOpts, _s.tipoSistSaneamiento,
                onChanged: (v) => setState(() => _s.tipoSistSaneamiento = v)),
            _err('Tipo de saneamiento'),
          ],

          const SizedBox(height: 14),
          _buildSingleSelect(
              '¿Cuál es el estado de la red de tuberías de desagüe dentro del establecimiento educativo? *',
              _estadoRedOpts, _s.estadoRedDesague,
              (v) => setState(() => _s.estadoRedDesague = v)),
          _err('Estado red de desagüe'),

          const SizedBox(height: 14),
          _numField('¿Número total de sanitarios y orinales con los que cuenta el establecimiento educativo? *', _totalSanitCtrl),
          _err('Total sanitarios y orinales'),

          const SizedBox(height: 14),
          _buildYesNo(
              '¿Hay unidades sanitarias separadas para niños y niñas en el establecimiento educativo? *',
              _s.sanitariosSeparados,
              (v) => setState(() => _s.sanitariosSeparados = v)),
          _err('Sanitarios separados'),

          if (_s.sanitariosSeparados == true) ...[
            const SizedBox(height: 10),
            _numField('Número de sanitarios para niñas *', _cantNinasCtrl),
            _err('Sanitarios para niñas'),
            const SizedBox(height: 10),
            _numField('Número de sanitarios y orinales para niños *', _cantNinosCtrl),
            _err('Sanitarios para niños'),
          ],

          const SizedBox(height: 14),
          _numField(
              'N° total de sanitarios y orinales que funcionan correctamente (Sirven las llaves, les llega el agua y descargan el agua) *',
              _totalFuncionanCtrl),
          _err('Sanitarios que funcionan'),

          const SizedBox(height: 14),
          _buildYesNo(
              '¿Existen instalaciones sanitarias adaptadas para personas con discapacidad? *',
              _s.instalacionesDiscapacidad,
              (v) => setState(() => _s.instalacionesDiscapacidad = v)),
          _err('Instalaciones para discapacidad'),

          if (_s.instalacionesDiscapacidad == true) ...[
            const SizedBox(height: 10),
            _numField('¿Cuántas instalaciones destinadas a personas con discapacidad? *',
                _cantDiscapCtrl),
            _err('Cantidad instalaciones discapacidad'),
          ],

          const SizedBox(height: 14),
          _buildYesNo(
              '¿Existen instalaciones sanitarias adaptadas para niños de primera infancia? *',
              _s.instalacionesPrimeraInfancia,
              (v) => setState(() => _s.instalacionesPrimeraInfancia = v)),
          _err('Instalaciones primera infancia'),

          if (_s.instalacionesPrimeraInfancia == true) ...[
            const SizedBox(height: 10),
            _numField(
                '¿Cuántas instalaciones estan destinadas a niños/as de primera infancia? *',
                _cantPrimerInfCtrl),
            _err('Cantidad instalaciones primera infancia'),
          ],

          const SizedBox(height: 14),
          _buildMultiCheck(
              '¿Las unidades sanitarias cuentan con? (selección múltiple) *',
              _condSanitariosOpts, _s.condicionesSanitarios,
              onChanged: (v) => setState(() => _s.condicionesSanitarios = v)),
          _err('Condiciones de sanitarios'),

          const SizedBox(height: 14),
          _buildMultiCheck(
              '¿La sede cuenta con gestión de desechos sólidos (recogida y eliminación de residuos), indique cual? *',
              _gestionDesechosOpts, _s.gestionDesechos,
              onChanged: (v) => setState(() => _s.gestionDesechos = v)),
          _err('Gestión de desechos'),

          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════
          //  HIGIENE
          // ═══════════════════════════════════════════════════
          const _SectionHeader('HIGIENE'),
          const SizedBox(height: 12),

          _buildMultiCheck('¿Con qué tipo de sistema de lavado de manos cuenta? *',
              _lavadoManoOpts, _s.sistemaLavadoManos,
              onChanged: (v) => setState(() => _s.sistemaLavadoManos = v)),
          _err('Lavado de manos'),

          const SizedBox(height: 14),
          _numField(
              'Número total de llaves y lavamanos funcionales (Sirven las llaves y les llega el agua) *',
              _totalLlavesCtrl),
          _err('Llaves y lavamanos funcionales'),

          const SizedBox(height: 14),
          _buildSingleSelect(
              '¿Con qué frecuencia cuentan los baños y lavamanos con papel higiénico y jabón líquido? *',
              _frecuenciaInsumosOpts, _s.frecuenciaInsumos,
              (v) => setState(() => _s.frecuenciaInsumos = v)),
          _err('Frecuencia de insumos'),

          const SizedBox(height: 14),
          _buildYesNo(
              '¿Hay información visual sobre hábitos y promoción de la higiene? *',
              _s.infoVisualHigiene,
              (v) => setState(() => _s.infoVisualHigiene = v)),
          _err('Información visual de higiene'),

          const SizedBox(height: 14),
          _buildYesNo(
              '¿Hay un comité o grupo activo encargado de actividades de agua, saneamiento e higiene? *',
              _s.tieneComiteASH,
              (v) => setState(() => _s.tieneComiteASH = v)),
          _err('Comité ASH'),

          if (_s.tieneComiteASH == true) ...[
            const SizedBox(height: 14),
            _buildSingleSelect(
                '¿El comité o grupo conformado se encuentra capacitado en operación y mantenimiento de los sistemas de agua y saneamiento en el establecimiento educativo? *',
                _capacitacionComiteOpts, _s.capacitacionComite,
                (v) => setState(() => _s.capacitacionComite = v)),
            _err('Capacitación del comité'),
          ],

          const SizedBox(height: 14),
          _buildMultiCheck(
              '¿Qué actividades de promoción en agua, saneamiento e higiene se realizan? *',
              _actividadesPromocionOpts, _s.actividadesPromocionASH,
              onChanged: (v) => setState(() => _s.actividadesPromocionASH = v)),
          _err('Actividades de promoción'),

          if (_s.actividadesPromocionASH.isNotEmpty &&
              !_s.actividadesPromocionASH.contains('No se realizan')) ...[
            const SizedBox(height: 14),
            _buildMultiCheck(
                '¿Quién lleva a cabo estas actividades de promoción? *',
                _quienPromocionOpts, _s.quienPromocionASH,
                onChanged: (v) => setState(() => _s.quienPromocionASH = v)),
            _err('Quién realiza la promoción'),
            const SizedBox(height: 14),
            _buildSingleSelect(
                '¿Con qué frecuencia se realizan estas actividades? *',
                _frecuenciaActOpts, _s.frecuenciaActividadesASH,
                (v) => setState(() => _s.frecuenciaActividadesASH = v)),
            _err('Frecuencia de actividades'),
          ],

          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════
          //  RIESGOS Y OBSERVACIONES
          // ═══════════════════════════════════════════════════
          const _SectionHeader('Riesgos y Observaciones'),
          const SizedBox(height: 12),

          _buildMultiCheck(
              '¿En el último año, ha experimentado la IE alguno de estos riesgos? *',
              _riesgosOpts, _s.riesgosExperimentados,
              onChanged: (v) => setState(() => _s.riesgosExperimentados = v)),
          _err('Riesgos experimentados'),

          if (_s.riesgosExperimentados.contains('Otro ¿Cuáles?')) ...[
            const SizedBox(height: 10),
            TextFormField(
              controller: _otroRiesgoCtrl,
              decoration: _inputDecor('Otro ¿Cuál? *'),
            ),
            _err('Otro riesgo'),
          ],

          const SizedBox(height: 14),
          TextFormField(
            controller: _observacionesCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              helperText:
                  '¿Podría proporcionar información adicional o hacer observaciones sobre el estado y la calidad de los servicios de agua, saneamiento e higiene en la sede educativa?',
              helperMaxLines: 5,
              labelText: 'Observaciones',
              hintText: 'Texto libre',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─────────────────────── helpers ───────────────────────

  InputDecoration _inputDecor(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      );

  Widget _numField(String label, TextEditingController ctrl) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'Numérico',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
            ),
          ),
        ],
      );

  Widget _buildYesNo(
    String label,
    bool? value,
    void Function(bool) onChanged,
  ) {
    return YesNoButtons(label: label, value: value, onChanged: onChanged);
  }

  Widget _buildTriState(
    String label, {
    required List<String> opts,
    required List<String> values,
    required String? value,
    required void Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 16,
          children: List.generate(opts.length, (i) => GestureDetector(
            onTap: () => onChanged(values[i]),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Radio<String>(
                value: values[i],
                groupValue: value,
                onChanged: (v) { if (v != null) onChanged(v); },
                activeColor: _green,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Text(opts[i], style: const TextStyle(fontSize: 14)),
            ]),
          )),
        ),
      ],
    );
  }

  Widget _buildSingleSelect(
    String label,
    List<String> opts,
    String? value,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 4),
        ...opts.map((opt) => RadioListTile<String>(
              dense: true,
              contentPadding: EdgeInsets.zero,
              value: opt,
              groupValue: value,
              title: Text(opt, style: const TextStyle(fontSize: 14)),
              activeColor: _green,
              onChanged: onChanged,
            )),
      ],
    );
  }

  Widget _buildRadioList(
    String label,
    List<String> opts,
    List<String> values,
    String? value,
    void Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 4),
        ...List.generate(opts.length, (i) => RadioListTile<String>(
              dense: true,
              contentPadding: EdgeInsets.zero,
              value: values[i],
              groupValue: value,
              title: Text(opts[i], style: const TextStyle(fontSize: 14)),
              activeColor: _green,
              onChanged: (v) { if (v != null) onChanged(v); },
            )),
      ],
    );
  }

  Widget _buildMultiCheck(
    String label,
    List<String> opts,
    List<String> selected, {
    required void Function(List<String>) onChanged,
    int? maxSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 4),
        ...opts.map((opt) {
          final checked = selected.contains(opt);
          return CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: checked,
            title: Text(opt, style: const TextStyle(fontSize: 14)),
            activeColor: _green,
            onChanged: (v) {
              final next = List<String>.from(selected);
              if (v == true) {
                if (maxSelect == null || next.length < maxSelect) next.add(opt);
              } else {
                next.remove(opt);
              }
              onChanged(next);
            },
          );
        }),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }
}
