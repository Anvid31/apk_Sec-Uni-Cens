import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/furniture_survey_state.dart';
import '../../widgets/layout/enhanced_form_container.dart';
import '../../widgets/form/photo_capture_field.dart';
import '../../utils/form_navigator.dart';
import 'furniture_items_page.dart';

class FurniturePhotosPage extends StatefulWidget {
  const FurniturePhotosPage({Key? key}) : super(key: key);

  @override
  State<FurniturePhotosPage> createState() => _FurniturePhotosPageState();
}

class _FurniturePhotosPageState extends State<FurniturePhotosPage> {
  late FurnitureSurveyState _surveyState;
  
  String? _photoPanoramica;
  String? _photoTablero;
  String? _photoCocina;
  String? _photoComedor;
  String? _photoInterna;

  @override
  void initState() {
    super.initState();
    _surveyState = Provider.of<FurnitureSurveyState>(context, listen: false);
    _loadData();
  }

  void _loadData() {
    _photoPanoramica = _surveyState.photoPanoramica;
    _photoTablero = _surveyState.photoTablero;
    _photoCocina = _surveyState.photoCocina;
    _photoComedor = _surveyState.photoComedor;
    _photoInterna = _surveyState.photoInterna;
  }

  void _onNext() {
    // Validar las 3 primeras fotos obligatorias
    // La lista visual es: Panorámica, Tablero, [Cocina], Comedor, Interna
    
    if (_photoPanoramica == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La Foto del Frente es obligatoria')));
      return;
    }
    if (_photoTablero == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La Foto del Aula 1 es obligatoria')));
      return;
    }

    // La foto del Aula 2 (variable _photoComedor) es la 3ra obligatoria del set base
    if (_photoComedor == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La Foto del Aula 2 es obligatoria')));
      return;
    }

    // Si tiene cocina, esta se vuelve la 4ta obligatoria
    if (_surveyState.hasCocina) {
       if (_photoCocina == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La Foto de la Cocina es obligatoria')));
        return;
      }
    }
    
    // Guardar en estado
    _surveyState.updatePhotos(
      photoPanoramica: _photoPanoramica,
      photoTablero: _photoTablero,
      photoCocina: _photoCocina,
      photoComedor: _photoComedor,
      photoInterna: _photoInterna,
    );

    FormNavigator.pushForm(
      context,
      const FurnitureItemsPage(),
      stepNumber: 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Consumir el estado para saber si requiere cocina
    final needsCocina = Provider.of<FurnitureSurveyState>(context).hasCocina;

    return EnhancedFormContainer(
      title: 'Registro Fotográfico',
      subtitle: 'Evidencia de la sede',
      currentStep: 4,
      totalSteps: 5,
      showPrevious: true,
      onPrevious: () => FormNavigator.popForm(context),
      onNext: _onNext,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Por favor tome las siguientes fotografías:',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            
            PhotoCaptureField(
              label: 'Foto Frente',
              imagePath: _photoPanoramica,
              onImageSelected: (path) => setState(() => _photoPanoramica = path),
              required: true,
            ),
            const SizedBox(height: 16),
            
            PhotoCaptureField(
              label: 'Foto Aula 1',
              imagePath: _photoTablero,
              onImageSelected: (path) => setState(() => _photoTablero = path),
              required: true,
            ),
            const SizedBox(height: 16),
            
            // Cocina es opcional dependiendo de si seleccionó que tiene cocina en infra
            if (needsCocina) ...[
              PhotoCaptureField(
                label: 'Foto Cocina',
                imagePath: _photoCocina,
                onImageSelected: (path) => setState(() => _photoCocina = path),
                required: true,
              ),
              const SizedBox(height: 16),
            ],

            PhotoCaptureField(
              label: 'Foto Aula 2',
              imagePath: _photoComedor,
              onImageSelected: (path) => setState(() => _photoComedor = path),
              required: true,
            ),
            const SizedBox(height: 16),
            
            PhotoCaptureField(
              label: 'Foto Comedor',
              imagePath: _photoInterna,
              onImageSelected: (path) => setState(() => _photoInterna = path),
              required: true,
            ),
          ],
        ),
      ),
    );
  }
}
