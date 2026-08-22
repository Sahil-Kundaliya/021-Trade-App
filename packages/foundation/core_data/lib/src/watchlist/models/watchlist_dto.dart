class WatchlistDto {
  WatchlistDto({
    required this.id,
    required this.name,
    required List<String> fundIds,
    required this.createdAt,
    required this.updatedAt,
  }) : fundIds = List<String>.unmodifiable(fundIds);

  factory WatchlistDto.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final rawFundIds = json['fundIds'];
    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '');
    final updatedAt = DateTime.tryParse(json['updatedAt']?.toString() ?? '');
    if (id is! String ||
        id.trim().isEmpty ||
        name is! String ||
        name.trim().isEmpty ||
        rawFundIds is! List ||
        rawFundIds.any((id) => id is! String || id.trim().isEmpty) ||
        createdAt == null ||
        updatedAt == null) {
      throw const FormatException('Invalid watchlist JSON.');
    }
    return WatchlistDto(
      id: id,
      name: name,
      fundIds: rawFundIds.cast<String>(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  final String id;
  final String name;
  final List<String> fundIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'fundIds': fundIds,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
