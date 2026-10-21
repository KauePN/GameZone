import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

  User? get currentUser => _supabase.auth.currentUser;

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return _supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'name': name.trim()},
    );
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> logout() => _supabase.auth.signOut();
}
