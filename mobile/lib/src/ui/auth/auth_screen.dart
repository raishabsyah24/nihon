import 'package:flutter/material.dart';

import '../../services/auth_controller.dart';
import '../common/async_content.dart';

enum _AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _AuthMode _mode = _AuthMode.login;
  String? _localError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.authController,
      builder: (context, _) {
        final auth = widget.authController;
        final disabled = auth.isBusy;
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              children: [
                _BrandHeader(mode: _mode),
                const SizedBox(height: 22),
                if (_localError != null || auth.errorMessage != null) ...[
                  InlineNotice(
                    icon: Icons.info_outline,
                    message: _localError ?? auth.errorMessage!,
                  ),
                  const SizedBox(height: 14),
                ],
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _mode == _AuthMode.login ? 'Masuk Akun' : 'Buat Akun',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 14),
                        _EmailFields(
                          emailController: _emailController,
                          passwordController: _passwordController,
                          confirmPasswordController: _confirmPasswordController,
                          showConfirm: _mode == _AuthMode.register,
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          onPressed: disabled ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFB4232A),
                            foregroundColor: Colors.white,
                          ),
                          icon: Icon(
                            _mode == _AuthMode.login
                                ? Icons.login_outlined
                                : Icons.person_add_alt_1_outlined,
                          ),
                          label: Text(
                            _mode == _AuthMode.login ? 'Masuk' : 'Register',
                          ),
                        ),
                        const SizedBox(height: 10),
                        _ModeSwitch(
                          mode: _mode,
                          disabled: disabled,
                          onChanged: (mode) => setState(() {
                            _mode = mode;
                            _localError = null;
                          }),
                        ),
                        if (_mode == _AuthMode.login) ...[
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: disabled ? null : auth.signInWithGoogle,
                            icon: const Icon(Icons.g_mobiledata_outlined),
                            label: const Text('Masuk dengan Google'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submit() {
    setState(() => _localError = null);

    if (_mode == _AuthMode.register &&
        _passwordController.text != _confirmPasswordController.text) {
      setState(() => _localError = 'Konfirmasi password belum sama.');
      return;
    }

    if (_mode == _AuthMode.login) {
      widget.authController.signInWithEmail(
        _emailController.text,
        _passwordController.text,
      );
    } else {
      widget.authController.registerWithEmail(
        _emailController.text,
        _passwordController.text,
      );
    }
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.mode});

  final _AuthMode mode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '日',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          mode == _AuthMode.login
              ? 'Masuk ke Nihon e Ikitai'
              : 'Register Nihon e Ikitai',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          'Belajar bahasa Jepang, latihan ujian, dan persiapan kerja dalam satu aplikasi.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _EmailFields extends StatelessWidget {
  const _EmailFields({
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.showConfirm,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool showConfirm;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.mail_outline),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: passwordController,
          obscureText: true,
          textInputAction: showConfirm
              ? TextInputAction.next
              : TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        if (showConfirm) ...[
          const SizedBox(height: 12),
          TextField(
            controller: confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Konfirmasi password',
              prefixIcon: Icon(Icons.lock_reset_outlined),
            ),
          ),
        ],
      ],
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({
    required this.mode,
    required this.disabled,
    required this.onChanged,
  });

  final _AuthMode mode;
  final bool disabled;
  final ValueChanged<_AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final isLogin = mode == _AuthMode.login;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isLogin ? 'Belum punya akun?' : 'Sudah punya akun?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: disabled
              ? null
              : () => onChanged(isLogin ? _AuthMode.register : _AuthMode.login),
          child: Text(isLogin ? 'Register' : 'Masuk'),
        ),
      ],
    );
  }
}
