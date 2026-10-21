class Validators {
  static String? required(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label é obrigatório.';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-mail é obrigatório.';
    }
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value.trim())) {
      return 'Digite um e-mail válido.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória.';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirme a senha.';
    }
    if (value != password) {
      return 'As senhas não coincidem.';
    }
    return null;
  }

  static String? year(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ano é obrigatório.';
    }
    final number = int.tryParse(value.trim());
    if (number == null || number < 1950 || number > DateTime.now().year + 2) {
      return 'Digite um ano válido.';
    }
    return null;
  }
}
