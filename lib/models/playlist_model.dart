class PlaylistModelX {
  final String id;
  final String name;
  final List<int> songIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PlaylistModelX({
    required this.id,
    required this.name,
    required this.songIds,
    required this.createdAt,
    required this.updatedAt,
  });

  PlaylistModelX copyWith({
    String? name,
    List<int>? songIds,
    DateTime? updatedAt,
  }) {
    return PlaylistModelX(
      id: id,
      name: name ?? this.name,
      songIds: songIds ?? this.songIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  factory PlaylistModelX.fromJson(Map<String, dynamic> json) {
    final rawIds = (json['songIds'] as List?) ?? const [];
    return PlaylistModelX(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      songIds: rawIds.map(_toInt).where((x) => x > 0).toList(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'songIds': songIds,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
