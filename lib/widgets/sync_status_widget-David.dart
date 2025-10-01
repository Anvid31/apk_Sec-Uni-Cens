import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/auto_sync_service.dart';

/// Widget que muestra el estado de sincronización en tiempo real
class SyncStatusWidget extends StatefulWidget {
  const SyncStatusWidget({super.key});

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget> {
  bool _hasConnectivity = false;
  int _pendingCount = 0;
  bool _isMonitoring = true;
  
  @override
  void initState() {
    super.initState();
    _initializeMonitoring();
  }

  Future<void> _initializeMonitoring() async {
    // Verificar estado inicial
    await _updateStatus();
    
    // Escuchar cambios de conectividad
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (mounted) {
        setState(() {
          _hasConnectivity = results.any((result) => result != ConnectivityResult.none);
        });
        
        // Si detectamos conectividad y hay pendientes, intentar sincronizar
        if (_hasConnectivity && _pendingCount > 0) {
          _trySync();
        }
      }
    });
    
    // Actualizar estado cada 30 segundos
    _startPeriodicUpdate();
  }

  void _startPeriodicUpdate() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _isMonitoring) {
        _updateStatus();
        _startPeriodicUpdate();
      }
    });
  }

  Future<void> _updateStatus() async {
    try {
      final status = await AutoSyncService.getSyncStatus();
      
      if (mounted) {
        setState(() {
          _hasConnectivity = status['hasConnectivity'] ?? false;
          _pendingCount = status['pendingCount'] ?? 0;
        });
      }
    } catch (e) {
      print('Error actualizando estado de sincronización: $e');
    }
  }

  Future<void> _trySync() async {
    try {
      // Usar el nuevo método de sincronización forzada
      await AutoSyncService.forceSyncNow();
      
      // Mostrar notificación de sincronización
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('Sincronizando formularios...'),
              ],
            ),
            backgroundColor: Colors.blue.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      // Actualizar estado después de la sincronización
      await _updateStatus();
    } catch (e) {
      print('Error en sincronización manual: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en sincronización: $e'),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _isMonitoring = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_pendingCount == 0) {
      return const SizedBox.shrink(); // No mostrar nada si no hay pendientes
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _hasConnectivity ? Colors.green.shade50 : Colors.orange.shade50,
        border: Border.all(
          color: _hasConnectivity ? Colors.green.shade300 : Colors.orange.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _hasConnectivity ? Icons.cloud_done : Icons.cloud_off,
            color: _hasConnectivity ? Colors.green.shade600 : Colors.orange.shade600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _hasConnectivity 
                    ? 'Conectado - Sincronizando automáticamente'
                    : 'Sin conexión - Esperando conectividad',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _hasConnectivity ? Colors.green.shade700 : Colors.orange.shade700,
                  ),
                ),
                Text(
                  '$_pendingCount encuesta(s) pendiente(s)',
                  style: TextStyle(
                    fontSize: 11,
                    color: _hasConnectivity ? Colors.green.shade600 : Colors.orange.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (_hasConnectivity && _pendingCount > 0)
            GestureDetector(
              onTap: _trySync,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Sincronizar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget flotante que muestra el estado de sincronización en cualquier pantalla
class FloatingSyncStatus extends StatelessWidget {
  const FloatingSyncStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: const SyncStatusWidget(),
    );
  }
}
