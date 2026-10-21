class GameModel {
  final String id;
  final String title;
  final String genre;
  final String platform;
  final int year;
  final String description;
  final String coverUrl;
  final DateTime? createdAt;

  const GameModel({
    this.id = '',
    required this.title,
    required this.genre,
    required this.platform,
    required this.year,
    required this.description,
    this.coverUrl = '',
    this.createdAt,
  });

  factory GameModel.fromMap(Map<String, dynamic> data) {
    return GameModel(
      id: data['id']?.toString() ?? '',
      title: data['title'] as String? ?? '',
      genre: data['genre'] as String? ?? '',
      platform: data['platform'] as String? ?? '',
      year: (data['year'] as num?)?.toInt() ?? 0,
      description: data['description'] as String? ?? '',
      coverUrl: data['cover_url'] as String? ?? '',
      createdAt: data['created_at'] == null
          ? null
          : DateTime.tryParse(data['created_at'].toString()),
    );
  }

  Map<String, dynamic> toInsertMap(String userId) {
    return {
      'user_id': userId,
      'title': title,
      'genre': genre,
      'platform': platform,
      'year': year,
      'description': description,
      'cover_url': coverUrl,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'title': title,
      'genre': genre,
      'platform': platform,
      'year': year,
      'description': description,
      'cover_url': coverUrl,
    };
  }
}
