class Watchlist {
  Watchlist({
    required this.id,
    required this.name,
    required List<String> fundIds,
    required this.createdAt,
    required this.updatedAt,
  }) : fundIds = List<String>.unmodifiable(fundIds);

  final String id;
  final String name;
  final List<String> fundIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Watchlist copyWith({
    String? name,
    List<String>? fundIds,
    DateTime? updatedAt,
  }) => Watchlist(
    id: id,
    name: name ?? this.name,
    fundIds: fundIds ?? this.fundIds,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
