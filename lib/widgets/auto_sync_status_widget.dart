import 'package:flutter/material.dart';
import 'dart:async';
import '../services/auto_sync_service.dart';

/// Widget que muestra el estado de sincronización en tiempo real
class AutoSyncStatusWidget extends StatefulWidget {
  /// Vista reducida para pantalla de inicio (sin botón de limpiar cola).
  final bool compact;

  const AutoSyncStatusWidget({super.key, this.compact = false});

  @override
  State<AutoSyncStatusWidget> createState() => _AutoSyncStatusWidgetState();
}

class _AutoSyncStatusWidgetState extends State<AutoSyncStatusWidget> {
  Timer? _timer;
  Map<String, dynamic> _syncStatus = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _startStatusUpdates();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startStatusUpdates() {
    _updateStatus();
    
    // Actualizar cada 2 segundos
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateStatus();
    });
  }

  Future<void> _updateStatus() async {
    try {
      final status = await AutoSyncService.getSyncStatus();
      if (mounted) {
        setState(() {
          _syncStatus = status;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _syncStatus = {'error': e.toString()};
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildStatusInfo(),
            if (!widget.compact) ...[
              const SizedBox(height: 16),
              _buildActionButtons(),
            ] else if ((_syncStatus['pendingCount'] ?? 0) > 0) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    try {
                      await AutoSyncService.forceSyncNow();
                      await _updateStatus();
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
                  icon: const Icon(Icons.sync, size: 16),
                  label: const Text('Sincronizar ahora'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final pendingCount = _syncStatus['pendingCount'] ?? 0;
    final hasConnectivity = _syncStatus['hasConnectivity'] ?? false;
    
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    if (_syncStatus.containsKey('error')) {
      statusColor = Colors.red;
      statusIcon = Icons.error;
      statusText = 'Error';
    } else if (pendingCount > 0) {
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
      statusText = 'Pendientes: $pendingCount';
    } else {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Sincronizado';
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            statusIcon,
            color: statusColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estado de Sincronización',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Indicador de conectividad
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: hasConnectivity ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasConnectivity ? Icons.wifi : Icons.wifi_off,
                color: hasConnectivity ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                hasConnectivity ? 'Online' : 'Offline',
                style: TextStyle(
                  color: hasConnectivity ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusInfo() {
    return Column(
      children: [
        if (_syncStatus['lastSuccessfulSync'] != null)
          _buildInfoRow(
            icon: Icons.check_circle_outline,
            label: 'Última sincronización',
            value: _formatDateTime(_syncStatus['lastSuccessfulSync']),
            color: Colors.green,
          ),
        if (_syncStatus['lastUpdate'] != null)
          _buildInfoRow(
            icon: Icons.update,
            label: 'Última actualización',
            value: _formatDateTime(_syncStatus['lastUpdate']),
            color: Colors.blue,
          ),
        if (_syncStatus['pendingCount'] != null && _syncStatus['pendingCount'] > 0)
          _buildInfoRow(
            icon: Icons.pending_actions,
            label: 'Encuestas pendientes',
            value: _syncStatus['pendingCount'].toString(),
            color: Colors.orange,
          ),
        if (_syncStatus['error'] != null)
          _buildInfoRow(
            icon: Icons.error_outline,
            label: 'Error',
            value: _syncStatus['error'],
            color: Colors.red,
          ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              await _updateStatus();
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Actualizar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              try {
                await AutoSyncService.forceSyncNow();
                await _updateStatus();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sincronización manual completada'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error en sincronización: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
              setState(() {
                _isLoading = false;
              });
            },
            icon: const Icon(Icons.sync, size: 16),
            label: const Text('Sincronizar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              final confirmed = await _showClearConfirmDialog();
              if (confirmed == true) {
                await AutoSyncService.clearPendingSurveys();
                await _updateStatus();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Encuestas pendientes limpiadas'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.clear_all, size: 16),
            label: const Text('Limpiar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Future<bool?> _showClearConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar limpieza'),
        content: const Text(
          '¿Está seguro de que desea limpiar todas las encuestas pendientes? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'Nunca';
    
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 1) {
        return 'Hace unos segundos';
      } else if (difference.inMinutes < 60) {
        return 'Hace ${difference.inMinutes} min';
      } else if (difference.inHours < 24) {
        return 'Hace ${difference.inHours} h';
      } else {
        return 'Hace ${difference.inDays} días';
      }
    } catch (e) {
      return 'Error en fecha';
    }
  }
}
