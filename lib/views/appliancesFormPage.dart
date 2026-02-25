import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/appliances_info.dart';
import '../models/survey_state.dart';
import '../widgets/layout/enhanced_form_container.dart';
import '../utils/form_navigator.dart';
import 'access_route_form_page.dart';

class AppliancesFormPage extends StatefulWidget {
  const AppliancesFormPage({super.key});

  @override
  State<AppliancesFormPage> createState() => _AppliancesFormPageState();
}

class _AppliancesFormPageState extends State<AppliancesFormPage> {
  late AppliancesInfo _appliancesInfo;
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final surveyState = Provider.of<SurveyState>(context, listen: false);
    _appliancesInfo = surveyState.appliancesInfo;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildApplianceItem(ApplianceItem appliance) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con nombre y botón eliminar
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: const Icon(
                    Icons.electrical_services,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    appliance.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Contenido principal
            Row(
              children: [
                // Campo de cantidad con botones
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cantidad',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                            width: 1,
                          ),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            // Botón disminuir
                            InkWell(
                              onTap: appliance.quantity > 0 
                                  ? () {
                                      setState(() {
                                        appliance.quantity--;
                                      });
                                    }
                                  : null,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                              child: Container(
                                width: 40,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: appliance.quantity > 0 
                                      ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                                      : Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: 20,
                                  color: appliance.quantity > 0 
                                      ? const Color(0xFF4CAF50)
                                      : Colors.grey.shade400,
                                ),
                              ),
                            ),
                            
                            // Campo numérico
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  appliance.quantity.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                              ),
                            ),
                            
                            // Botón aumentar
                            InkWell(
                              onTap: () {
                                setState(() {
                                  appliance.quantity++;
                                });
                              },
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                              child: Container(
                                width: 40,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 20,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                
                // Estado de uso
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¿En uso?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(12),
                                ),
                                onTap: () {
                                  setState(() {
                                    appliance.isInUse = true;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: appliance.isInUse == true
                                        ? const Color(0xFF4CAF50)
                                        : Colors.transparent,
                                    borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: appliance.isInUse == true
                                            ? Colors.white
                                            : Colors.grey.shade400,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Sí',
                                        style: TextStyle(
                                          color: appliance.isInUse == true
                                              ? Colors.white
                                              : Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey.shade300,
                            ),
                            Expanded(
                              child: InkWell(
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(12),
                                ),
                                onTap: () {
                                  setState(() {
                                    appliance.isInUse = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: appliance.isInUse == false
                                        ? Colors.red.shade400
                                        : Colors.transparent,
                                    borderRadius: const BorderRadius.horizontal(
                                      right: Radius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.cancel,
                                        size: 16,
                                        color: appliance.isInUse == false
                                            ? Colors.white
                                            : Colors.grey.shade400,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'No',
                                        style: TextStyle(
                                          color: appliance.isInUse == false
                                              ? Colors.white
                                              : Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddApplianceDialog() {
    final TextEditingController nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.electrical_services,
                  color: Color(0xFF4CAF50),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Agregar Electrodoméstico',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ingrese el nombre del electrodoméstico o equipo eléctrico:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.grey.shade50,
                ),
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del electrodoméstico',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    hintText: 'Ej: Ventilador, Televisor, Lavadora...',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  autofocus: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                final String name = nameController.text.trim();
                if (name.isNotEmpty) {
                  // Verificar si ya existe un electrodoméstico con el mismo nombre
                  if (_appliancesInfo.appliances.any((item) => 
                      item.name.toLowerCase() == name.toLowerCase())) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.warning, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Ya existe un electrodoméstico con ese nombre'),
                          ],
                        ),
                        backgroundColor: Colors.orange.shade600,
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                    return;
                  }

                  setState(() {
                    _appliancesInfo.appliances.add(
                      ApplianceItem(name: name)
                    );
                  });

                  // Actualizar el estado global
                  Provider.of<SurveyState>(context, listen: false)
                      .updateAppliancesInfo(_appliancesInfo);

                  Navigator.of(context).pop();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('$name agregado correctamente'),
                        ],
                      ),
                      backgroundColor: const Color(0xFF4CAF50),
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                'Agregar',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return EnhancedFormContainer(
      title: 'Electrodomésticos',
      subtitle: 'Equipos eléctricos del hogar',
      currentStep: 6,
      onPrevious: () => FormNavigator.popForm(context),
      onNext: _submitForm,
      nextLabel: 'Siguiente',
      showPrevious: true,
      transitionType: FormTransitionType.slideScale,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header con descripción
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4CAF50).withValues(alpha: 0.1),
                        const Color(0xFF4CAF50).withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.electrical_services,
                        size: 32,
                        color: Color(0xFF4CAF50),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Electrodomésticos y Equipos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2E2E),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Registre los electrodomésticos y equipos eléctricos disponibles en el hogar',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Lista de electrodomésticos
                if (_appliancesInfo.appliances.isEmpty)
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.electrical_services_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay electrodomésticos registrados',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Toca el botón "Agregar Electrodoméstico" para empezar',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Botón agregar electrodoméstico (cuando la lista está vacía)
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        child: Material(
                          elevation: 0,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _showAddApplianceDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF4CAF50),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4CAF50),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Flexible(
                                    child: Text(
                                      'Agregar Electrodoméstico',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF4CAF50),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  ..._appliancesInfo.appliances.map((appliance) => 
                    _buildApplianceItem(appliance),
                  ).toList(),
                
                // Botón agregar electrodoméstico (al final de la lista)
                if (_appliancesInfo.appliances.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 16, bottom: 24),
                    child: Material(
                      elevation: 0,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _showAddApplianceDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF4CAF50),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Flexible(
                                child: Text(
                                  'Agregar Electrodoméstico',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4CAF50),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 80), // Espacio para los botones fijos
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      Provider.of<SurveyState>(context, listen: false)
          .updateAppliancesInfo(_appliancesInfo);
      
      // Usar el nuevo sistema de navegación con transiciones suaves
      FormNavigator.pushForm(
        context,
        const AccessRouteFormPage(),
        type: FormTransitionType.slideScale,
        stepNumber: 7,
      );
    } else {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }
}
