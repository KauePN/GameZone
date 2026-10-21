
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/game_model.dart';
import '../services/game_service.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';

class GameFormScreen extends StatefulWidget {
  final GameModel? game;

  const GameFormScreen({super.key, this.game});

  bool get editing => game != null;

  @override
  State<GameFormScreen> createState() => _GameFormScreenState();
}

class _GameFormScreenState extends State<GameFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _title;
  late final TextEditingController _genre;
  late final TextEditingController _platform;
  late final TextEditingController _year;
  late final TextEditingController _description;
  late final TextEditingController _coverUrl;

  final _picker = ImagePicker();

  Uint8List? _imageBytes;
  String? _imageExtension;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    final game = widget.game;

    _title = TextEditingController(text: game?.title ?? '');
    _genre = TextEditingController(text: game?.genre ?? '');
    _platform = TextEditingController(text: game?.platform ?? '');
    _year = TextEditingController(text: game?.year.toString() ?? '');
    _description =
        TextEditingController(text: game?.description ?? '');
    _coverUrl = TextEditingController(text: game?.coverUrl ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _genre.dispose();
    _platform.dispose();
    _year.dispose();
    _description.dispose();
    _coverUrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (file == null) return;

      final name = file.name.toLowerCase();
      final extension = name.contains('.')
          ? name.split('.').last
          : '';

      if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
        _message('Selecione uma imagem JPG, JPEG, PNG ou WebP.');
        return;
      }

      final bytes = await file.readAsBytes();

      if (bytes.length > 5 * 1024 * 1024) {
        _message('A imagem deve ter no máximo 5 MB.');
        return;
      }

      if (!mounted) return;

      setState(() {
        _imageBytes = bytes;
        _imageExtension = extension == 'jpg' ? 'jpeg' : extension;
      });
    } catch (e) {
      _message('Não foi possível selecionar a imagem: $e');
    }
  }

  Future<void> _uploadImage() async {
    if (_imageBytes == null || _imageExtension == null) return;

    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) {
      throw Exception('Entre na sua conta para enviar uma imagem.');
    }

    final extension = _imageExtension!;
    final path =
        '${user.id}/${DateTime.now().microsecondsSinceEpoch}.$extension';

    final contentType = extension == 'jpeg'
        ? 'image/jpeg'
        : extension == 'png'
            ? 'image/png'
            : 'image/webp';

    await client.storage.from('game-covers').uploadBinary(
      path,
      _imageBytes!,
      fileOptions: FileOptions(
        contentType: contentType,
      ),
    );

    _coverUrl.text =
        client.storage.from('game-covers').getPublicUrl(path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      if (_imageBytes != null) {
        await _uploadImage();
      }

      final game = GameModel(
        id: widget.game?.id ?? '',
        title: _title.text.trim(),
        genre: _genre.text.trim(),
        platform: _platform.text.trim(),
        year: int.parse(_year.text.trim()),
        description: _description.text.trim(),
        coverUrl: _coverUrl.text.trim(),
        createdAt: widget.game?.createdAt,
      );

      if (widget.editing) {
        await GameService().updateGame(game);
      } else {
        await GameService().addGame(game);
      }

      if (!mounted) return;

      _message(
        widget.editing
            ? 'Jogo atualizado com sucesso!'
            : 'Jogo cadastrado com sucesso!',
      );

      Navigator.pop(context, true);
    } catch (e) {
      _message('Erro ao salvar: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editing ? 'Editar jogo' : 'Novo jogo'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _title,
                      label: 'Nome do jogo',
                      icon: Icons.title,
                      validator: (v) =>
                          Validators.required(v, 'Nome do jogo'),
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _genre,
                      label: 'Gênero',
                      icon: Icons.category_outlined,
                      validator: (v) =>
                          Validators.required(v, 'Gênero'),
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _platform,
                      label: 'Plataforma',
                      icon: Icons.devices_outlined,
                      validator: (v) =>
                          Validators.required(v, 'Plataforma'),
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _year,
                      label: 'Ano de lançamento',
                      icon: Icons.calendar_today_outlined,
                      validator: Validators.year,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _description,
                      label: 'Descrição',
                      icon: Icons.description_outlined,
                      maxLines: 4,
                      validator: (v) =>
                          Validators.required(v, 'Descrição'),
                    ),
                    const SizedBox(height: 20),

                    if (_imageBytes != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _imageBytes!,
                          height: 200,
                          width: 160,
                          fit: BoxFit.cover,
                        ),
                      )
                    else if (_coverUrl.text.trim().isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _coverUrl.text.trim(),
                          height: 200,
                          width: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image, size: 60),
                        ),
                      ),

                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _loading ? null : _pickImage,
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('Selecionar imagem'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Formatos: JPG, JPEG, PNG e WebP. Máximo: 5 MB.',
                    ),
                    const SizedBox(height: 14),

                    CustomTextField(
                      controller: _coverUrl,
                      label: 'URL da capa (opcional)',
                      icon: Icons.link,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loading ? null : _save,
                      child: _loading
                          ? const CircularProgressIndicator(
                              strokeWidth: 2,
                            )
                          : Text(
                              widget.editing
                                  ? 'SALVAR ALTERAÇÕES'
                                  : 'CADASTRAR JOGO',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
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
