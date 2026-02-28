import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/furniture_survey_state.dart';
import '../../models/furniture_item.dart';
import '../../widgets/layout/enhanced_form_container.dart';
import '../../widgets/form/repeating_icon_button.dart';
import '../../utils/form_navigator.dart';

class FurnitureItemsPage extends StatefulWidget {
  const FurnitureItemsPage({Key? key}) : super(key: key);

  @override
  State<FurnitureItemsPage> createState() => _FurnitureItemsPageState();
}

class _FurnitureItemsPageState extends State<FurnitureItemsPage> {
  late FurnitureSurveyState _surveyState;

  // Dotación Cocina
  bool _tieneCocina = false;
  final TextEditingController _necMobiliarioCocinaCtrl =
      TextEditingController();
  final TextEditingController _necUtensiliosCocinaCtrl =
      TextEditingController();

  // Dotación Emergencia
  bool _necesitaBotiquin = false;
  final TextEditingController _necEmergenciaCtrl = TextEditingController();

  List<FurnitureItem> _filteredItems = [];
  final Map<String, TextEditingController> _quantityControllers = {};

  TextEditingController _getQtyCtrl(String key, int initialValue) {
    return _quantityControllers.putIfAbsent(
      key,
      () => TextEditingController(text: '$initialValue'),
    );
  }

  @override
  void dispose() {
    _necMobiliarioCocinaCtrl.dispose();
    _necUtensiliosCocinaCtrl.dispose();
    _necEmergenciaCtrl.dispose();
    for (final ctrl in _quantityControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _surveyState = Provider.of<FurnitureSurveyState>(context, listen: false);
    _filteredItems = _surveyState.items;
    _loadDotationData();
  }

  void _loadDotationData() {
    _tieneCocina = _surveyState.tieneCocina;
    _necMobiliarioCocinaCtrl.text = _surveyState.necesidadesMobiliarioCocina;
    _necUtensiliosCocinaCtrl.text = _surveyState.necesidadesUtensiliosCocina;

    _necesitaBotiquin = _surveyState.necesitaBotiquin;
    _necEmergenciaCtrl.text = _surveyState.necesidadesEmergencia;
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _surveyState.items;
      } else {
        _filteredItems =
            _surveyState.items.where((item) {
              return item.name.toLowerCase().contains(query.toLowerCase()) ||
                  item.code.toLowerCase().contains(query.toLowerCase());
            }).toList();
      }
    });
  }

  Future<void> _onSubmit() async {
    // Confirmación antes de enviar
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Confirmar Envío',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            '¿Está seguro de que desea finalizar y enviar la encuesta?\n\nVerifique que toda la información esté correcta antes de continuar.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                elevation: 0,
              ),
              child: const Text(
                'Enviar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    // Guardar datos de dotación antes de enviar
    _surveyState.updateDotation(
      tieneCocina: _tieneCocina,
      necesidadesMobiliarioCocina: _necMobiliarioCocinaCtrl.text,
      necesidadesUtensiliosCocina: _necUtensiliosCocinaCtrl.text,
      necesitaBotiquin: _necesitaBotiquin,
      necesidadesEmergencia: _necEmergenciaCtrl.text,
    );

    // Validar si es necesario
    try {
      await _surveyState.submit();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Encuesta guardada y sincronizada correctamente'),
        ),
      );

      // Navigate back to home or selection page
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return EnhancedFormContainer(
      title: 'Inventario de Mobiliario',
      subtitle: 'Registro de ítems',
      currentStep: 5,
      totalSteps: 5,
      showPrevious: true,
      onPrevious: () => FormNavigator.popForm(context),
      onNext: _onSubmit,
      nextLabel: 'FINALIZAR',
      customScrolling: true, // Habilitar scroll personalizado para ListView
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: _filteredItems.length + 1, // +1 para la sección final
              itemBuilder: (ctx, i) {
                if (i == _filteredItems.length) {
                  return _buildDotationSection();
                }
                final item = _filteredItems[i];
                return _buildItemCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotationSection() {
    return Container(
      margin: const EdgeInsets.only(top: 24, left: 0, right: 0, bottom: 40),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Dotación Especial',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  final Uri url = Uri.parse(
                    'https://www.mineducacion.gov.co/1759/articles-355996_archivo_pdf_manual_dotaciones.pdf',
                  );
                  if (!await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  )) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No se pudo abrir el manual'),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.indigo,
                  size: 20,
                ),
                label: const Text(
                  'Ver Manual MEN',
                  style: TextStyle(color: Colors.indigo),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Cocina
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.indigo.shade100),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.restaurant, color: Colors.indigo),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¿Cuenta la sede educativa con comedor-cocina?',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 4),
                          ],
                        ),
                      ),
                      Switch(
                        value: _tieneCocina,
                        onChanged: (val) => setState(() => _tieneCocina = val),
                        activeColor: Colors.indigo,
                      ),
                    ],
                  ),
                  if (_tieneCocina) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Ej: 1 Nevera, 2 congeladores, 1 licuadora, 1 recipiente plastico, 2 balde plastico, 1 caldero, 1 ollas aluminio recortado, 1olla a presión, 1 olleta, 1 paila, 2 sartén, 1 jarra plastica, 1 tabla para picar, 3 cucharon, 2 rallador, 2 coladores, 1 asador antiaderente, 1 batidor de chocolate, 1 exprimidor manual, 1 olla arrocera, 1 balanza gramera, 1 cafetera, 50 cucharas, 60 tenedor, 60 cuchillo,30  plato hondo, 40 plato pando grande y pequeño, 80 posillos, 70 vasos, etc.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.indigo.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _necMobiliarioCocinaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Mobiliario de Cocina',
                        hintText: 'Indique cantidades y elementos requeridos',
                        border: OutlineInputBorder(),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ej: 1 mesón con azafates, 1 mesón de trabajo cocina, 2 mesa de cafeteria plegable, 1 estufa enana de un quemador, 1 estufa lineal de tres quemadores, etc.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.indigo.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _necUtensiliosCocinaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Menaje, Equipo y Utensilios de Cocina',
                        hintText: 'Indique cantidades y elementos requeridos',
                        border: OutlineInputBorder(),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      maxLines: 3,
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Botiquín / Emergencia
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.indigo.shade100),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.medical_services, color: Colors.indigo),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¿Considera necesario la dotación de Mobiliario para la Atención de Emergencias?',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 4),
                          ],
                        ),
                      ),
                      Switch(
                        value: _necesitaBotiquin,
                        onChanged:
                            (val) => setState(() => _necesitaBotiquin = val),
                        activeColor: Colors.indigo,
                      ),
                    ],
                  ),
                  if (_necesitaBotiquin) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Ej: 2 camillas, 1 Escalinata 2 peldaños, 3 botiquin gavinete fijo, 5 caneca riesgo biologico, 1 contenedor de punzantes, 3 báscula con tallímetro, etc.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.indigo.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _necEmergenciaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Mobiliario para la Atención de Emergencias',
                        hintText: 'Indique cantidades y elementos requeridos',
                        border: OutlineInputBorder(),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      maxLines: 3,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(FurnitureItem item) {
    final hasSubItems = item.subItems != null && item.subItems!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FILA SUPERIOR: Nombre e Indicador de Cantidad (si no hay subitems)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      if (item.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            item.description,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Si NO tiene subitems, mostramos el control de cantidad aquí arriba
                if (!hasSubItems) ...[
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RepeatingIconButton(
                          icon: const Icon(Icons.remove, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          onPressed:
                              item.quantity > 0
                                  ? () {
                                    setState(() {
                                      item.quantity--;
                                      _quantityControllers[item.code]?.text =
                                          '${item.quantity}';
                                    });
                                  }
                                  : null,
                        ),
                        SizedBox(
                          width: 48,
                          child: TextField(
                            controller: _getQtyCtrl(item.code, item.quantity),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  item.quantity > 0
                                      ? Colors.blue.shade700
                                      : Colors.black54,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (val) {
                              final parsed = int.tryParse(val);
                              if (parsed != null && parsed >= 0) {
                                setState(() => item.quantity = parsed);
                              }
                            },
                          ),
                        ),
                        RepeatingIconButton(
                          icon: const Icon(Icons.add, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          onPressed: () {
                            setState(() {
                              item.quantity++;
                              _quantityControllers[item.code]?.text =
                                  '${item.quantity}';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // SUBITEMS (si tiene)
            if (hasSubItems) ...[
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children:
                      item.subItems!
                          .map(
                            (sub) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      sub.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),

                                  // Control cantidad subitem compacto
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    height: 36,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        RepeatingIconButton(
                                          icon: const Icon(
                                            Icons.remove,
                                            size: 16,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                            minWidth: 32,
                                            minHeight: 32,
                                          ),
                                          onPressed:
                                              sub.quantity > 0
                                                  ? () {
                                                    setState(() {
                                                      sub.quantity--;
                                                      item.quantity = item
                                                          .subItems!
                                                          .fold(
                                                            0,
                                                            (sum, e) =>
                                                                sum +
                                                                e.quantity,
                                                          );
                                                      _quantityControllers['${item.code}_${sub.name}']
                                                              ?.text =
                                                          '${sub.quantity}';
                                                    });
                                                  }
                                                  : null,
                                        ),
                                        SizedBox(
                                          width: 44,
                                          child: TextField(
                                            controller: _getQtyCtrl(
                                              '${item.code}_${sub.name}',
                                              sub.quantity,
                                            ),
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                            onChanged: (val) {
                                              final parsed = int.tryParse(val);
                                              if (parsed != null &&
                                                  parsed >= 0) {
                                                setState(() {
                                                  sub.quantity = parsed;
                                                  item.quantity = item.subItems!
                                                      .fold(
                                                        0,
                                                        (sum, e) =>
                                                            sum + e.quantity,
                                                      );
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                        RepeatingIconButton(
                                          icon: const Icon(Icons.add, size: 16),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                            minWidth: 32,
                                            minHeight: 32,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              sub.quantity++;
                                              item.quantity = item.subItems!
                                                  .fold(
                                                    0,
                                                    (sum, e) =>
                                                        sum + e.quantity,
                                                  );
                                              _quantityControllers['${item.code}_${sub.name}']
                                                  ?.text = '${sub.quantity}';
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
              // Total visual para subitems
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Total Calculado: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // CAMPO DE OBSERVACIONES (Full width)
            TextFormField(
              initialValue: item.observations,
              decoration: InputDecoration(
                labelText: 'Observaciones',
                hintText: 'Ingrese las observaciones necesarias...',
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                isDense: true,
              ),
              maxLines: 2,
              minLines: 1,
              onChanged: (val) => item.observations = val,
            ),
          ],
        ),
      ),
    );
  }
}
