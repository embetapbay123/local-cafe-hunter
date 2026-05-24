class CafeCollection {
  const CafeCollection({
    required this.id,
    required this.name,
    required this.cafeIds,
  });

  final String id;
  final String name;
  final List<String> cafeIds;

  CafeCollection copyWith({
    String? id,
    String? name,
    List<String>? cafeIds,
  }) {
    return CafeCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      cafeIds: cafeIds ?? this.cafeIds,
    );
  }
}
