class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageKey,
    this.description = '',
    this.isRecommended = false,
  });

  final String id;
  final String name;
  final String category;
  final int price;
  final String imageKey;
  final String description;
  final bool isRecommended;
}
