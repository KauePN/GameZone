import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/game_model.dart';

class GameService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<List<GameModel>> watchGames() {
  return _supabase
      .from('games')
      .stream(primaryKey: ['id'])
      .order('title')
      .map(
        (rows) => rows
            .map(GameModel.fromMap)
            .toList(growable: false),
      );
}

  Future<void> addGame(GameModel game) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AuthException('Usuário não autenticado.');
    }

    await _supabase.from('games').insert(game.toInsertMap(user.id));
  }

  Future<void> updateGame(GameModel game) async {
  if (game.id.isEmpty) {
    throw Exception('ID do jogo não informado.');
  }

  final result = await _supabase
      .from('games')
      .update(game.toUpdateMap())
      .eq('id', game.id)
      .select('id');

  if (result.isEmpty) {
    throw Exception(
      'Nenhum jogo foi atualizado. Verifique se você tem permissão para editar este jogo.',
    );
  }
}



  
Future<void> deleteGame(String id) async {
  final user = _supabase.auth.currentUser;

  if (user == null) {
    throw Exception('Você precisa estar logado para excluir um jogo.');
  }

  final result = await _supabase
      .from('games')
      .delete()
      .eq('id', id)
      .select('id');

  if (result.isEmpty) {
    throw Exception(
      'O jogo não foi excluído. Verifique as permissões do Supabase.',
    );
  }
}

}
