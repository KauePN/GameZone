
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getComments(
    String gameId,
  ) async {
    final result = await _supabase
        .from('game_comments')
        .select()
        .eq('game_id', gameId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(result);
  }

  Future<void> addComment({
    required String gameId,
    required String content,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Faça login para comentar.');
    }

    final text = content.trim();

    if (text.isEmpty || text.length > 1000) {
      throw Exception(
        'O comentário deve ter entre 1 e 1000 caracteres.',
      );
    }

    final name = user.userMetadata?['name']?.toString()
        ?? user.email?.split('@').first
        ?? 'Usuário';

    await _supabase.from('game_comments').insert({
      'game_id': gameId,
      'user_id': user.id,
      'user_name': name,
      'content': text,
    });
  }

  Future<void> deleteComment(String commentId) async {
    await _supabase
        .from('game_comments')
        .delete()
        .eq('id', commentId);
  }
}
