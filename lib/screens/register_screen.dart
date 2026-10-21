import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gamezone_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await _auth.register(
        name: _name.text,
        email: _email.text,
        password: _password.text,
      );
      if (!mounted) return;
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Conta criada! Verifique seu e-mail para confirmar o cadastro.',
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      final message = switch (e.code) {
        'user_already_exists' => 'Este e-mail já está cadastrado.',
        'weak_password' => 'A senha é muito fraca.',
        'invalid_email' => 'E-mail inválido.',
        _ => e.message.isNotEmpty
            ? e.message
            : 'Não foi possível criar a conta.',
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
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const GameZoneLogo(size: 70),
                    const SizedBox(height: 28),
                    CustomTextField(
                      controller: _name,
                      label: 'Nome',
                      icon: Icons.person_outline,
                      validator: (v) => Validators.required(v, 'Nome'),
                    ),
                    const SizedBox(height: 14),
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
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _confirm,
                      label: 'Confirme a senha',
                      icon: Icons.lock_reset_outlined,
                      obscureText: true,
                      validator: (v) =>
                          Validators.confirmPassword(v, _password.text),
                    ),
                    const SizedBox(height: 22),
                    ElevatedButton(
                      onPressed: _loading ? null : _register,
                      child: _loading
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : const Text(
                              'CRIAR CONTA',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
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
