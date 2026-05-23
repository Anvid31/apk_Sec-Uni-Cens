// ignore_for_file: avoid_print

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import '../services/update_service.dart';

/// Diálogo de actualización disponible.
///
/// Uso:
/// ```dart
/// final info = await UpdateService.checkForUpdate();
/// if (info != null && context.mounted) {
///   showUpdateDialog(context, info);
/// }
/// ```
void showUpdateDialog(BuildContext context, UpdateInfo info) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => UpdateDialog(info: info),
  );
}

class UpdateDialog extends StatefulWidget {
  final UpdateInfo info;

  const UpdateDialog({super.key, required this.info});

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  _Phase _phase = _Phase.available;
  double _progress = 0;
  String? _errorMessage;
  CancelToken? _cancelToken;

  @override
  void dispose() {
    _cancelToken?.cancel('Dialog cerrado');
    super.dispose();
  }

  Future<void> _startDownload() async {
    if (!widget.info.hasDownload) {
      setState(() => _errorMessage = 'No se encontró un APK en el release.');
      return;
    }

    setState(() {
      _phase = _Phase.downloading;
      _progress = 0;
      _errorMessage = null;
      _cancelToken = CancelToken();
    });

    try {
      final path = await UpdateService.downloadUpdate(
        widget.info.downloadUrl!,
        cancelToken: _cancelToken,
        onProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() => _progress = received / total);
          }
        },
      );

      if (mounted) {
        setState(() => _phase = _Phase.ready);
        await _installApk(path);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        if (mounted) setState(() => _phase = _Phase.available);
      } else {
        if (mounted) {
          setState(() {
            _phase = _Phase.error;
            _errorMessage = 'Error de red: ${e.message}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _phase = _Phase.error;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _installApk(String path) async {
    try {
      if (!Platform.isAndroid) return;
      final result = await OpenFile.open(path, type: 'application/vnd.android.package-archive');
      print('📦 UpdateDialog: open_file result: ${result.message}');
    } catch (e) {
      if (mounted) {
        setState(() {
          _phase = _Phase.error;
          _errorMessage = 'No se pudo abrir el instalador: $e';
        });
      }
    }
  }

  void _cancel() {
    _cancelToken?.cancel('Usuario canceló');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cabecera con color
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: _headerColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Icon(_headerIcon, size: 48, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  _headerTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Cuerpo
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildBody(),
          ),

          // Botones
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: _buildActions(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_phase) {
      case _Phase.available:
        return _buildAvailableBody();
      case _Phase.downloading:
        return _buildDownloadingBody();
      case _Phase.ready:
        return _buildReadyBody();
      case _Phase.error:
        return _buildErrorBody();
    }
  }

  Widget _buildAvailableBody() {
    final notes = widget.info.releaseNotes.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _versionChip('Actual', widget.info.currentVersion, Colors.grey),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
            ),
            _versionChip('Nueva', widget.info.latestVersion, Colors.green),
          ],
        ),
        if (notes.isNotEmpty) ...[
          const SizedBox(height: 14),
          const Text(
            'Novedades',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Container(
            constraints: const BoxConstraints(maxHeight: 120),
            child: SingleChildScrollView(
              child: Text(
                notes,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),
          ),
        ],
        if (!widget.info.hasDownload) ...[
          const SizedBox(height: 10),
          const Text(
            '⚠️ No hay APK adjunto en este release.',
            style: TextStyle(color: Colors.orange, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildDownloadingBody() {
    final percent = (_progress * 100).toStringAsFixed(0);
    return Column(
      children: [
        const Text(
          'Descargando actualización...',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _progress > 0 ? _progress : null,
            minHeight: 10,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _progress > 0 ? '$percent%' : 'Iniciando...',
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildReadyBody() {
    return const Column(
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 40),
        SizedBox(height: 8),
        Text(
          'Descarga completa.\nAbriendo instalador del sistema...',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildErrorBody() {
    return Column(
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 40),
        const SizedBox(height: 8),
        Text(
          _errorMessage ?? 'Error desconocido.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: Colors.red),
        ),
      ],
    );
  }

  Widget _buildActions() {
    switch (_phase) {
      case _Phase.available:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _cancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Después'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: widget.info.hasDownload ? _startDownload : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Actualizar'),
              ),
            ),
          ],
        );

      case _Phase.downloading:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _cancel,
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('Cancelar'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        );

      case _Phase.ready:
        return const SizedBox.shrink();

      case _Phase.error:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _cancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Cerrar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _startDownload,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Reintentar'),
              ),
            ),
          ],
        );
    }
  }

  Widget _versionChip(String label, String version, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11, color: Colors.grey.shade600)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Text(
            'v$version',
            style: TextStyle(
              color: color.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Color get _headerColor {
    switch (_phase) {
      case _Phase.available:
        return const Color(0xFF2E7D32); // verde oscuro
      case _Phase.downloading:
        return const Color(0xFF1565C0); // azul
      case _Phase.ready:
        return const Color(0xFF2E7D32);
      case _Phase.error:
        return const Color(0xFFC62828); // rojo
    }
  }

  IconData get _headerIcon {
    switch (_phase) {
      case _Phase.available:
        return Icons.system_update_alt;
      case _Phase.downloading:
        return Icons.downloading;
      case _Phase.ready:
        return Icons.check_circle_outline;
      case _Phase.error:
        return Icons.error_outline;
    }
  }

  String get _headerTitle {
    switch (_phase) {
      case _Phase.available:
        return 'Actualización disponible\n${widget.info.releaseName}';
      case _Phase.downloading:
        return 'Descargando...';
      case _Phase.ready:
        return 'Lista para instalar';
      case _Phase.error:
        return 'Error al descargar';
    }
  }
}

enum _Phase { available, downloading, ready, error }

extension on Color {
  Color get shade700 {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();
  }
}
