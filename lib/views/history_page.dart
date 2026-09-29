import 'package:flutter/material.dart';
import '../config/tokens.dart';
import '../services/auto_sync_service.dart';
import '../services/supabase_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<_HistoryData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_HistoryData> _load() async {
    final results = await Future.wait([
      AutoSyncService.getPendingSurveys(),
      SupabaseService.querySurveysForHistory(),
    ]);
    return _HistoryData(
      pending: results[0],
      synced: results[1],
    );
  }

  void _refresh() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<_HistoryData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _ErrorState(
              message: snap.error.toString(),
              onRetry: _refresh,
            );
          }
          final data = snap.data!;
          if (data.pending.isEmpty && data.synced.isEmpty) {
            return _EmptyState(scheme: scheme);
          }
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: CustomScrollView(
              slivers: [
                if (data.pending.isNotEmpty) ...[
                  _SectionHeader(
                    label: 'Pendientes de sincronización',
                    count: data.pending.length,
                    color: scheme.error,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _SurveyTile(
                        entry: _entryFromPending(data.pending[i]),
                        scheme: scheme,
                      ),
                      childCount: data.pending.length,
                    ),
                  ),
                ],
                if (data.synced.isNotEmpty) ...[
                  _SectionHeader(
                    label: 'Enviadas',
                    count: data.synced.length,
                    color: Colors.green.shade700,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _SurveyTile(
                        entry: _entryFromSynced(data.synced[i]),
                        scheme: scheme,
                      ),
                      childCount: data.synced.length,
                    ),
                  ),
                ],
                const SliverToBoxAdapter(
                  child: SizedBox(height: Insets.xxl),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Modelos internos ────────────────────────────────────────────────────────

class _HistoryData {
  const _HistoryData({required this.pending, required this.synced});
  final List<Map<String, dynamic>> pending;
  final List<Map<String, dynamic>> synced;
}

enum _Status { pending, error, synced }

class _Entry {
  const _Entry({
    required this.id,
    required this.institution,
    required this.municipality,
    required this.date,
    required this.status,
  });
  final String id;
  final String institution;
  final String municipality;
  final DateTime? date;
  final _Status status;
}

_Entry _entryFromPending(Map<String, dynamic> raw) {
  final syncStatus = raw['syncStatus'] as String? ?? 'pending';
  final status =
      syncStatus == 'error' ? _Status.error : _Status.pending;

  final ts = raw['timestamp'] as String?;
  final date = ts != null ? DateTime.tryParse(ts) : null;

  final payload = _extractPayload(raw);
  return _Entry(
    id: raw['id']?.toString() ?? '',
    institution: _extractInstitution(raw, payload),
    municipality: _extractMunicipality(raw, payload),
    date: date,
    status: status,
  );
}

_Entry _entryFromSynced(Map<String, dynamic> raw) {
  final ts = raw['created_at'] as String?;
  final date = ts != null ? DateTime.tryParse(ts) : null;
  return _Entry(
    id: raw['id']?.toString() ?? '',
    institution: raw['institution']?.toString() ?? 'Sin nombre',
    municipality: raw['municipality']?.toString() ?? '',
    date: date,
    status: _Status.synced,
  );
}

Map<String, dynamic>? _extractPayload(Map<String, dynamic> raw) {
  final nested = raw['data'] ?? raw['datos'];
  if (nested is Map<String, dynamic>) return nested;
  if (raw.containsKey('schoolName') ||
      raw.containsKey('institutionalInfo') ||
      raw.containsKey('informacionInstitucional')) {
    return raw;
  }
  return null;
}

String _extractInstitution(
  Map<String, dynamic> raw,
  Map<String, dynamic>? payload,
) {
  final instInfo = (payload?['informacionInstitucional'] ??
      payload?['institutionalInfo']) as Map<String, dynamic>?;
  return instInfo?['institutionName'] as String? ??
      instInfo?['nombreInstitucion'] as String? ??
      payload?['institutionName'] as String? ??
      payload?['schoolName'] as String? ??
      raw['institutionName'] as String? ??
      'Sin nombre';
}

String _extractMunicipality(
  Map<String, dynamic> raw,
  Map<String, dynamic>? payload,
) {
  final genInfo = (payload?['informacionGeneral'] ??
      payload?['generalInfo']) as Map<String, dynamic>?;
  return genInfo?['municipality'] as String? ??
      genInfo?['municipio'] as String? ??
      payload?['municipality'] as String? ??
      raw['municipality'] as String? ??
      '';
}

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.count,
    required this.color,
  });
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Insets.lg,
          Insets.xl,
          Insets.lg,
          Insets.sm,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: text.labelLarge?.copyWith(color: color),
            ),
            const SizedBox(width: Insets.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Insets.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.all(Radii.sm),
              ),
              child: Text(
                '$count',
                style: text.labelSmall?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurveyTile extends StatelessWidget {
  const _SurveyTile({required this.entry, required this.scheme});
  final _Entry entry;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final (icon, iconColor, chipLabel, chipColor) = switch (entry.status) {
      _Status.synced => (
          Icons.cloud_done_outlined,
          Colors.green.shade700,
          'Enviada',
          Colors.green.shade700,
        ),
      _Status.error => (
          Icons.cloud_off_outlined,
          scheme.error,
          'Error',
          scheme.error,
        ),
      _Status.pending => (
          Icons.cloud_upload_outlined,
          Colors.orange.shade700,
          'Pendiente',
          Colors.orange.shade700,
        ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Insets.lg,
        vertical: Insets.xs,
      ),
      child: Material(
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.card,
          side: BorderSide(color: scheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Insets.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(Insets.sm),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.all(Radii.md),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: Insets.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.institution,
                      style: text.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (entry.municipality.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        entry.municipality,
                        style: text.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: Insets.sm),
                    Row(
                      children: [
                        _Chip(label: chipLabel, color: chipColor),
                        if (entry.date != null) ...[
                          const SizedBox(width: Insets.sm),
                          Text(
                            _formatDate(entry.date!),
                            style: text.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    final y = local.year;
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min';
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Insets.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: const BorderRadius.all(Radii.sm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: Insets.lg),
          Text(
            'No hay encuestas registradas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: Insets.sm),
          Text(
            'Las encuestas enviadas y pendientes\naparecerán aquí.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Insets.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: scheme.error),
            const SizedBox(height: Insets.lg),
            Text(
              'Error al cargar el historial',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Insets.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: Insets.xl),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
