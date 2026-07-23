class ShoppingList {
  const ShoppingList({
    required this.id,
    required this.familyId,
    required this.name,
    required this.createdAt,
    this.isArchived = false,
    this.sortOrder = 0,
  });

  final String id;
  final String familyId;
  final String name;
  final DateTime createdAt;
  final bool isArchived;
  final int sortOrder;

  ShoppingList copyWith({
    String? name,
    bool? isArchived,
    int? sortOrder,
  }) {
    return ShoppingList(
      id: id,
      familyId: familyId,
      name: name ?? this.name,
      createdAt: createdAt,
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'familyId': familyId,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'isArchived': isArchived,
        'sortOrder': sortOrder,
      };

  factory ShoppingList.fromJson(Map<String, Object?> json) {
    return ShoppingList(
      id: json['id'] as String? ?? '',
      familyId: json['familyId'] as String? ?? '',
      name: json['name'] as String? ?? 'קניות',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      isArchived: json['isArchived'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }
}
