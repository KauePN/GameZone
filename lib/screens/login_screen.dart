import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gamezone_logo.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await _auth.login(email: _email.text, password: _password.text);
    } on AuthException catch (e) {
      if (!mounted) return;
      final message = switch (e.code) {
        'invalid_credentials' => 'E-mail ou senha incorretos.',
        'email_not_confirmed' =>
          'Confirme seu e-mail antes de entrar.',
        'invalid_email' => 'E-mail inválido.',
        'user_not_found' => 'Usuário não encontrado.',
        'over_request_rate_limit' =>
          'Muitas tentativas. Tente novamente mais tarde.',
        _ => e.message.isNotEmpty
            ? e.message
            : 'Não foi possível entrar. Verifique os dados.',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const GameZoneLogo(size: 82),
                    const SizedBox(height: 42),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Bem-vindo de volta!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Entre para acessar sua biblioteca de jogos.'),
                    ),
                    const SizedBox(height: 28),
                    CustomTextField(
                      controller: _email,
                      label: 'E-mail',
                      icon: Icons.email_outlined,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _password,
                      label: 'Senha',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 22),
                    ElevatedButton(
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'ENTRAR',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
                      child: const Text('Ainda não tenho uma conta'),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'GameZone • AV1 Flutter/Dart',
                      style: TextStyle(color: Colors.white.withValues(alpha: .55)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
