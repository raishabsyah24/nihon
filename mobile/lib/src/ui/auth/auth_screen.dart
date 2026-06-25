import 'package:flutter/material.dart';

import '../../services/auth_controller.dart';
import '../common/async_content.dart';

enum _AuthMode { login, register }

enum _AuthMethod { email, phone }

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
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  _AuthMode _mode = _AuthMode.login;
  _AuthMethod _method = _AuthMethod.email;
  String? _localError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
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
                SegmentedButton<_AuthMethod>(
                  segments: const [
                    ButtonSegment(
                      value: _AuthMethod.email,
                      icon: Icon(Icons.mail_outline),
                      label: Text('Email'),
                    ),
                    ButtonSegment(
                      value: _AuthMethod.phone,
                      icon: Icon(Icons.phone_outlined),
                      label: Text('Nomor HP'),
                    ),
                  ],
                  selected: {_method},
                  onSelectionChanged: disabled
                      ? null
                      : (value) => setState(() {
                          _method = value.first;
                          _localError = null;
                        }),
                ),
                const SizedBox(height: 18),
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
                        if (_method == _AuthMethod.email)
                          _EmailFields(
                            emailController: _emailController,
                            passwordController: _passwordController,
                            confirmPasswordController:
                                _confirmPasswordController,
                            showConfirm: _mode == _AuthMode.register,
                          )
                        else
                          _PhoneFields(
                            phoneController: _phoneController,
                            otpController: _otpController,
                            disabled: disabled,
                            onSendOtp: () =>
                                auth.sendPhoneCode(_phoneController.text),
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
                        if (_mode == _AuthMode.login &&
                            _method == _AuthMethod.email) ...[
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
                const SizedBox(height: 20),
                _DemoAccess(authController: auth),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submit() {
    setState(() => _localError = null);

    if (_method == _AuthMethod.email) {
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
      return;
    }

    widget.authController.verifyPhoneCode(_otpController.text);
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

class _PhoneFields extends StatelessWidget {
  const _PhoneFields({
    required this.phoneController,
    required this.otpController,
    required this.disabled,
    required this.onSendOtp,
  });

  final TextEditingController phoneController;
  final TextEditingController otpController;
  final bool disabled;
  final VoidCallback onSendOtp;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Nomor HP internasional',
            hintText: '+628123456789',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            onPressed: disabled ? null : onSendOtp,
            icon: const Icon(Icons.sms_outlined),
            label: const Text('Kirim OTP'),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Kode OTP',
            prefixIcon: Icon(Icons.password_outlined),
          ),
        ),
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

class _DemoAccess extends StatelessWidget {
  const _DemoAccess({required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    final disabled = authController.isBusy;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        TextButton(
          onPressed: disabled
              ? null
              : () => authController.useDemoUser(admin: false),
          child: const Text('Demo User'),
        ),
        TextButton(
          onPressed: disabled
              ? null
              : () => authController.useDemoUser(admin: true),
          child: const Text('Demo Admin'),
        ),
      ],
    );
  }
}
