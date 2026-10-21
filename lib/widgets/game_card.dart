
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/game_model.dart';
import '../services/comment_service.dart';
import '../theme/app_theme.dart';

class GameCard extends StatefulWidget {
  final GameModel game;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GameCard({
    super.key,
    required this.game,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  final _service = CommentService();
  final _controller = TextEditingController();

  List<Map<String, dynamic>> _comments = [];
  bool _loading = true;
  bool _sending = false;
  bool _expanded = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final comments =
          await _service.getComments(widget.game.id);

      if (!mounted) return;
      setState(() {
        _comments = comments;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _message('Erro ao carregar comentários: $e');
    }
  }

  Future<void> _sendComment() async {
    final content = _controller.text.trim();

    if (content.isEmpty) {
      _message('Escreva um comentário primeiro.');
      return;
    }

    if (content.length > 1000) {
      _message('O comentário pode ter até 1000 caracteres.');
      return;
    }

    setState(() => _sending = true);

    try {
      await _service.addComment(
        gameId: widget.game.id,
        content: content,
      );

      _controller.clear();
      await _loadComments();

      if (mounted) _message('Comentário publicado!');
    } catch (e) {
      _message('Não foi possível comentar: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _deleteComment(
    Map<String, dynamic> comment,
  ) async {
    try {
      await _service.deleteComment(
        comment['id'].toString(),
      );
      await _loadComments();
      if (mounted) _message('Comentário excluído.');
    } catch (e) {
      _message('Erro ao excluir comentário: $e');
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                
Container(
  width: 58,
  height: 72,
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppTheme.primary,
        AppTheme.secondary,
      ],
    ),
    borderRadius: BorderRadius.circular(12),
  ),
  clipBehavior: Clip.antiAlias,
  child: widget.game.coverUrl != null &&
          widget.game.coverUrl!.trim().isNotEmpty
      ? Image.network(
          widget.game.coverUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.videogame_asset_rounded,
              color: Colors.white,
              size: 30,
            );
          },
        )
      : const Icon(
          Icons.videogame_asset_rounded,
          color: Colors.white,
          size: 30,
        ),
),

                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.game.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${widget.game.genre} • ${widget.game.platform}',
                      ),
                      
if (widget.game.description.trim().isNotEmpty)
  Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text(
      widget.game.description,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
      ),
    ),
  ),

                      const SizedBox(height: 3),
                      Text('Lançamento: ${widget.game.year}'),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') widget.onEdit();
                    if (value == 'delete') widget.onDelete();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Editar'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Excluir'),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 28),
            InkWell(
              onTap: () => setState(
                () => _expanded = !_expanded,
              ),
              child: Row(
                children: [
                  const Icon(Icons.forum_outlined),
                  const SizedBox(width: 8),
                  Text(
                    'Comentários (${_comments.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _expanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                  ),
                ],
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLength: 1000,
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Escreva um comentário...',
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _sendComment,
                    tooltip: 'Publicar comentário',
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_loading)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else if (_comments.isEmpty)
                const Text('Ainda não há comentários.')
              else
                ..._comments.map((comment) {
                  final date = DateTime.tryParse(
                    comment['created_at'].toString(),
                  );
                  final isOwner =
                      comment['user_id'] == userId;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(Icons.person_outline),
                    ),
                    title: Text(
                      comment['user_name']?.toString() ??
                          'Usuário',
                    ),
                    subtitle: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(comment['content'].toString()),
                        if (date != null)
                          Text(
                            date.toLocal().toString().substring(
                              0,
                              16,
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall,
                          ),
                      ],
                    ),
                    trailing: isOwner
                        ? IconButton(
                            tooltip: 'Excluir meu comentário',
                            icon: const Icon(
                              Icons.delete_outline,
                            ),
                            onPressed: () =>
                                _deleteComment(comment),
                          )
                        : null,
                  );
                }),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _loadComments,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Atualizar comentários'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
