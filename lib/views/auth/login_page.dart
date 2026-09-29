import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../config/tokens.dart';
import '../selection_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await SupabaseService.signIn(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SelectionPage()),
      );
    } on AuthException catch (e) {
      setState(() => _errorMessage = _friendlyError(e.message));
    } catch (e) {
      setState(() => _errorMessage = 'Error de conexión. Verifica tu red.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('Invalid login')) return 'Correo o contraseña incorrectos.';
    if (raw.contains('Email not confirmed')) {
      return 'Confirma tu correo antes de iniciar sesión.';
    }
    if (raw.contains('network') || raw.contains('connection')) {
      return 'Sin conexión a internet.';
    }
    return 'Error al iniciar sesión. Intenta de nuevo.';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header verde ────────────────────────────────────────────────
            Expanded(
              flex: 2,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.assignment_turned_in_outlined,
                      size: 72,
                      color: colors.onPrimary,
                    ),
                    const SizedBox(height: Insets.md),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: Insets.xl),
                      child: Text(
                        'Caracterización y Mapeo de Necesidades I.E.',
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: colors.onPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ),
                    const SizedBox(height: Insets.xs),
                    Text(
                      'Sedes Educativas',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colors.onPrimary.withOpacity(0.8),
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Card de login ─────────────────────────────────────────────
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: Radii.sheet,
                ),
                padding: const EdgeInsets.all(Insets.xl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Iniciar sesión',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: Insets.lg),

                      // Email
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          hintText: 'docente@cens.edu.co',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: Radii.input,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Ingresa tu correo';
                          }
                          if (!v.contains('@')) return 'Correo inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: Insets.md),

                      // Contraseña
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _onLogin(),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: Radii.input,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                          if (v.length < 6) return 'Mínimo 6 caracteres';
                          return null;
                        },
                      ),

                      // Error
                      if (_errorMessage != null) ...[
                        const SizedBox(height: Insets.md),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Insets.md,
                            vertical: Insets.sm,
                          ),
                          decoration: BoxDecoration(
                            color: colors.errorContainer,
                            borderRadius: const BorderRadius.all(Radii.sm),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: colors.onErrorContainer, size: 18),
                              const SizedBox(width: Insets.sm),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                      color: colors.onErrorContainer,
                                      fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const Spacer(),

                      // Botón
                      FilledButton(
                        onPressed: _isLoading ? null : _onLogin,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: const RoundedRectangleBorder(
                            borderRadius: Radii.button,
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Iniciar sesión',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                      const SizedBox(height: Insets.md),
                      Text(
                        'Tu cuenta es creada por el administrador CENS.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
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
    );
  }
}
