import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/tokens.dart';
import '../services/supabase_service.dart';
import '../services/update_service.dart';
import '../widgets/update_dialog.dart';
import '../widgets/auto_sync_status_widget.dart';
import 'auth/login_page.dart';
import 'history_page.dart';
import 'unified/phase1_info_general_page.dart';

class SelectionPage extends StatefulWidget {
  const SelectionPage({Key? key}) : super(key: key);

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  Future<void> _onLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que deseas cerrar la sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await SupabaseService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  Future<void> _checkForUpdate() async {
    try {
      final info = await UpdateService.checkForUpdate(force: true);
      if (info != null && mounted) {
        showUpdateDialog(context, info);
      }
    } catch (_) {
      // Silencioso: no interrumpir el flujo si la verificación falla.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.secondary,
              scheme.primary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Botón de logout (solo si hay sesión activa)
              if (SupabaseService.isAuthenticated)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: Insets.sm,
                      right: Insets.md,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.logout,
                        color: scheme.onPrimary.withValues(alpha: 0.75),
                      ),
                      tooltip: 'Cerrar sesión',
                      onPressed: _onLogout,
                    ),
                  ),
                ),
              const SizedBox(height: Insets.lg),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_turned_in_outlined,
                      size: 72,
                      color: scheme.onPrimary,
                    ),
                    const SizedBox(height: Insets.xl),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: Insets.xl),
                      child: Text(
                        'Caracterización y Mapeo de Necesidades I.E.',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: scheme.onPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: Insets.sm),
                    Text(
                      'Seleccione el tipo de registro',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: scheme.onPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Insets.xl,
                    vertical: Insets.xxl,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: Radii.sheet,
                  ),
                  child: Column(
                    children: [
                      const AutoSyncStatusWidget(compact: true),
                      const SizedBox(height: Insets.lg),
                      _HomeActionTile(
                        key: const ValueKey('tile_formulario'),
                        title: 'Formulario de Caracterización',
                        subtitle:
                            'Información general, dotación, energía, agua y riesgo.',
                        icon: Icons.assignment_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Phase1InfoGeneralPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: Insets.xl),
                      _HomeActionTile(
                        key: const ValueKey('tile_historial'),
                        title: 'Historial',
                        subtitle: 'Encuestas enviadas y pendientes.',
                        icon: Icons.history_rounded,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HistoryPage(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeActionTile extends StatelessWidget {
  const _HomeActionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: Radii.card,
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.card,
        child: Padding(
          padding: const EdgeInsets.all(Insets.xl),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Insets.md),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: const BorderRadius.all(Radii.md),
                ),
                child: Icon(icon, color: scheme.primary, size: 28),
              ),
              const SizedBox(width: Insets.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: Insets.xs),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
