import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class PhotoCaptureField extends StatefulWidget {
  final String label;
  final String? imagePath;
  final void Function(String?) onImageSelected;
  final String? hintText;
  final bool required;

  const PhotoCaptureField({
    super.key,
    required this.label,
    this.imagePath,
    required this.onImageSelected,
    this.hintText,
    this.required = false,
  });

  @override
  State<PhotoCaptureField> createState() => _PhotoCaptureFieldState();
}

class _PhotoCaptureFieldState extends State<PhotoCaptureField> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _showImagePickerOptions() async {
    try {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Seleccionar imagen',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildOptionButton(
                        icon: Icons.camera_alt,
                        label: 'Cámara',
                        onTap: () {
                          Navigator.pop(context);
                          _takePicture();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildOptionButton(
                        icon: Icons.photo_library,
                        label: 'Galería',
                        onTap: () {
                          Navigator.pop(context);
                          _pickFromGallery();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (widget.imagePath != null && widget.imagePath!.isNotEmpty) ...[
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _removeImage();
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Eliminar imagen', style: TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(height: 10),
                ],
                // Botón para cancelar
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print('Error al mostrar opciones de imagen: $e');
      // Fallback a botones simples si el modal falla
      _showSimpleOptions();
    }
  }

  void _showSimpleOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar imagen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(context);
                _takePicture();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            if (widget.imagePath != null && widget.imagePath!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar imagen', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _removeImage();
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: const Color(0xFF4CAF50)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Future<void> _takePicture() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      try {
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
          preferredCameraDevice: CameraDevice.rear,
        );

        if (photo != null && mounted) {
          widget.onImageSelected(photo.path);
          _showSuccessMessage('Foto capturada exitosamente');
        }
      } on PlatformException catch (e) {
        if (mounted) {
          String errorMessage = 'Error al acceder a la cámara';
          
          if (e.code == 'camera_access_denied') {
            errorMessage = 'Permisos de cámara denegados. Ve a Configuración > Aplicaciones > ${_getAppName()} > Permisos para habilitarlos.';
          } else if (e.code == 'no_available_camera') {
            errorMessage = 'No hay cámara disponible en este dispositivo.';
          } else if (e.message?.contains('permission') == true) {
            errorMessage = 'Sin permisos de cámara. Verifica la configuración de la aplicación.';
          }
          
          _showErrorMessage(errorMessage);
          print('Error de cámara PlatformException: ${e.code} - ${e.message}');
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error inesperado al acceder a la cámara';
        
        if (e.toString().contains('permission')) {
          errorMessage = 'Sin permisos de cámara. Verifica la configuración.';
        } else if (e.toString().contains('camera')) {
          errorMessage = 'La cámara no está disponible.';
        }
        
        _showErrorMessage('$errorMessage: ${e.toString()}');
        print('Error de cámara general: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      try {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );

        if (image != null && mounted) {
          widget.onImageSelected(image.path);
          _showSuccessMessage('Imagen seleccionada exitosamente');
        }
      } on PlatformException catch (e) {
        if (mounted) {
          String errorMessage = 'Error al acceder a la galería';
          
          if (e.code == 'photo_access_denied') {
            errorMessage = 'Permisos de galería denegados. Ve a Configuración > Aplicaciones > ${_getAppName()} > Permisos para habilitarlos.';
          } else if (e.message?.contains('permission') == true) {
            errorMessage = 'Sin permisos de almacenamiento. Verifica la configuración de la aplicación.';
          }
          
          _showErrorMessage(errorMessage);
          print('Error de galería PlatformException: ${e.code} - ${e.message}');
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error inesperado al acceder a la galería';
        
        if (e.toString().contains('permission')) {
          errorMessage = 'Sin permisos de almacenamiento. Verifica la configuración.';
        }
        
        _showErrorMessage('$errorMessage: ${e.toString()}');
        print('Error de galería general: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getAppName() {
    // En un caso real, esto podría obtenerse del package_info_plus
    return 'CaracT Móvil';
  }

  void _removeImage() {
    widget.onImageSelected(null);
    _showSuccessMessage('Imagen eliminada');
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Ayuda',
          textColor: Colors.white,
          onPressed: () {
            _showPermissionDialog();
          },
        ),
      ),
    );
  }

  void _showPermissionDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permisos Requeridos'),
        content: const Text(
          'Para usar la cámara y galería, la aplicación necesita los siguientes permisos:\n\n'
          '• Acceso a la cámara\n'
          '• Acceso a fotos y archivos multimedia\n\n'
          'Ve a Configuración del dispositivo > Aplicaciones > CaracT Móvil > Permisos para habilitarlos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2C3E50),
              ),
            ),
            if (widget.required) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isLoading ? null : _showImagePickerOptions,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF4CAF50),
                        ),
                        SizedBox(height: 8),
                        Text('Procesando...'),
                      ],
                    ),
                  )
                : widget.imagePath != null && widget.imagePath!.isNotEmpty
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildImageWidget(),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      )
                    : _buildPlaceholder(),
          ),
        ),
        // Botones opcionales como alternativa si el tap no funciona
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _takePicture,
                icon: const Icon(Icons.camera_alt, size: 18),
                label: const Text('Cámara', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4CAF50),
                  side: const BorderSide(color: Color(0xFF4CAF50)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _pickFromGallery,
                icon: const Icon(Icons.photo_library, size: 18),
                label: const Text('Galería', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2196F3),
                  side: const BorderSide(color: Color(0xFF2196F3)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            if (widget.imagePath != null && widget.imagePath!.isNotEmpty) ...[
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _removeImage,
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Eliminar', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildImageWidget() {
    try {
      if (widget.imagePath!.startsWith('http')) {
        return Image.network(
          widget.imagePath!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        );
      } else {
        final file = File(widget.imagePath!);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder();
            },
          );
        } else {
          return _buildPlaceholder();
        }
      }
    } catch (e) {
      print('Error al cargar imagen: $e');
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo,
          size: 48,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 8),
        Text(
          widget.hintText ?? 'Toca para agregar una foto',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Cámara o Galería',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
