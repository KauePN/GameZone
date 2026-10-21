import 'package:flutter/material.dart';

import '../models/game_model.dart';
import '../services/auth_service.dart';
import '../services/game_service.dart';
import '../theme/app_theme.dart';
import '../widgets/game_card.dart';
import 'game_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().authStateChanges;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GAMEZONE',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: () => AuthService().logout(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GameFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Novo jogo'),
      ),
      body: StreamBuilder(
        stream: user,
        builder: (context, authSnapshot) {
          if (!authSnapshot.hasData) {
            return const SizedBox.shrink();
          }

          return StreamBuilder<List<GameModel>>(
            stream: GameService().watchGames(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Não foi possível carregar os jogos.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final games = snapshot.data ?? [];

              if (games.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sports_esports_outlined,
                          size: 72,
                          color: AppTheme.secondary,
                        ),
                        SizedBox(height: 18),
                        Text(
                          'Sua biblioteca está vazia',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Use “Novo jogo” para cadastrar seu primeiro jogo.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
                itemCount: games.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final game = games[index];

                  return GameCard(
                    game: game,
                    onEdit: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GameFormScreen(game: game),
                      ),
                    ),
                    onDelete: () => _confirmDelete(context, game),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, GameModel game) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir jogo?'),
        content: Text('O registro “${game.title}” será excluído.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await GameService().deleteGame(game.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jogo excluído com sucesso.')),
        );
      }
    }
  }
}
