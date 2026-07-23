class ShoppingList {
  const ShoppingList({
    required this.id,
    required this.familyId,
    required this.name,
    required this.createdAt,
  });

  final String id;
  final String familyId;
  final String name;
  final DateTime createdAt;

  ShoppingList copyWith({String? name}) {
    return ShoppingList(
      id: id,
      familyId: familyId,
      name: name ?? this.name,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'familyId': familyId,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ShoppingList.fromJson(Map<String, Object?> json) {
    return ShoppingList(
      id: json['id'] as String? ?? '',
      familyId: json['familyId'] as String? ?? '',
      name: json['name'] as String? ?? 'קניות',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
