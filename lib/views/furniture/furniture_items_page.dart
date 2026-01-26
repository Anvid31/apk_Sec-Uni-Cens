import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/furniture_survey_state.dart';
import '../../models/furniture_item.dart';
import '../../widgets/layout/enhanced_form_container.dart';
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
  final TextEditingController _necMobiliarioCocinaCtrl = TextEditingController();
  final TextEditingController _necUtensiliosCocinaCtrl = TextEditingController();

  // Dotación Emergencia
  bool _necesitaBotiquin = false;
  final TextEditingController _necEmergenciaCtrl = TextEditingController();

  List<FurnitureItem> _filteredItems = [];

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
        _filteredItems = _surveyState.items.where((item) {
          return item.name.toLowerCase().contains(query.toLowerCase()) ||
                 item.code.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _onSubmit() async {
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
        const SnackBar(content: Text('Encuesta guardada y sincronizada correctamente')),
      );
      
      // Navigate back to home or selection page
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
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
      margin: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 40),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
              ),
              TextButton.icon(
                 onPressed: () async {
                   final Uri url = Uri.parse('https://www.mineducacion.gov.co/1759/articles-319520_archivo_pdf.pdf');
                   if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                     if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir el manual')));
                     }
                   }
                 },
                 icon: const Icon(Icons.picture_as_pdf, color: Colors.indigo, size: 20),
                 label: const Text('Ver Manual MEN', style: TextStyle(color: Colors.indigo)),
               ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Cocina
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.indigo.shade100)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       const Icon(Icons.restaurant, color: Colors.indigo),
                       const SizedBox(width: 12),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                              const Text('¿Cuenta la sede educativa con comedor-cocina?', style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                                'Si su respuesa es SÍ indiquenos en la casilla de observaciones que elementos y cantidades se requieren teniendo en cuenta el manual de dotación escolar MEN',
                                style: TextStyle(fontSize: 12, color: Colors.indigo.shade800, fontStyle: FontStyle.italic),
                              ),
                           ],
                         )
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
                    TextFormField(
                      controller: _necMobiliarioCocinaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Mobiliario de Cocina',
                        hintText: 'mesón con azafates, mesón de trabajo cocina...',
                        helperText: '(mesón con azafates, mesón de trabajo cocina, mesa de cafeteria plegable, estufa enana de un quemador, estufa lineal de tres quemadores, etc)',
                        helperMaxLines: 3,
                        border: OutlineInputBorder(),
                        isDense: true,
                        filled: true,
                         fillColor: Colors.white,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _necUtensiliosCocinaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Menaje, Equipo y Utensilios de Cocina',
                        hintText: 'Nevera, congelador, licuadora...',
                        helperText: '(Nevera, congelador, licuadora, recipiente plastico, balde plastico,caldero, ollas aluminio recortado, olla a presión, olleta, paila, sartén, etc)',
                        helperMaxLines: 3,
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.indigo.shade100)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       const Icon(Icons.medical_services, color: Colors.indigo),
                       const SizedBox(width: 12),
                       Expanded(
                         child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             const Text('¿Considera necesario la dotación de Mobiliario para la Atención de Emergencias?', style: TextStyle(fontWeight: FontWeight.w600)),
                             const SizedBox(height: 4),
                             Text(
                               'Si su respuesa es SÍ indiquenos en la casilla de observaciones que elementos y cantidades se requieren teniendo en cuenta el manual de dotación escolar MEN',
                               style: TextStyle(fontSize: 12, color: Colors.indigo.shade800, fontStyle: FontStyle.italic),
                             ),
                           ],
                         )
                       ),
                       Switch(
                         value: _necesitaBotiquin,
                         onChanged: (val) => setState(() => _necesitaBotiquin = val),
                         activeColor: Colors.indigo,
                       ),
                    ],
                  ),
                  if (_necesitaBotiquin) ...[
                     const SizedBox(height: 16),
                     TextFormField(
                      controller: _necEmergenciaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Mobiliario para la Atención de Emergencias',
                        hintText: 'camilla, Escalinata 2 peldaños...',
                        helperText: '(camilla, Escalinata 2 peldaños, botiquin gavinete fijo, caneca riesgo biologico, contenedor de punzantes, báscula con tallimetro, etc)',
                        helperMaxLines: 3,
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            if (item.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Text(
                  item.description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ),
            
            if (hasSubItems)
              ...item.subItems!.map((sub) => Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: Text('• ${sub.name}', style: const TextStyle(fontSize: 13))),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      onPressed: sub.quantity > 0 ? () {
                         setState(() {
                           sub.quantity--;
                           item.quantity = item.subItems!.fold(0, (sum, e) => sum + e.quantity);
                         });
                      } : null,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('${sub.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                       onPressed: () {
                         setState(() {
                           sub.quantity++;
                           item.quantity = item.subItems!.fold(0, (sum, e) => sum + e.quantity);
                         });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              )).toList(),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item.observations,
                    decoration: const InputDecoration(
                      labelText: 'Estado / Observaciones',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => item.observations = val,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 12)),
                    Row(
                      children: [
                        if (!hasSubItems)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: item.quantity > 0 ? () {
                            setState(() => item.quantity--);
                          } : null,
                        ),
                        
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.quantity > 0 ? Colors.green.shade50 : null,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${item.quantity}',
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                              color: item.quantity > 0 ? Colors.green.shade800 : Colors.black,
                            ),
                          ),
                        ),
                        
                        if (!hasSubItems)
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            setState(() => item.quantity++);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
