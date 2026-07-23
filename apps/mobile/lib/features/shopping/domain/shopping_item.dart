import 'shopping_category.dart';

class ShoppingItem {
  const ShoppingItem({
    required this.id,
    required this.familyId,
    required this.name,
    required this.quantity,
    required this.note,
    required this.category,
    required this.isChecked,
    required this.createdAt,
  });

  final String id;
  final String familyId;
  final String name;
  final String quantity;
  final String note;
  final ShoppingCategory category;
  final bool isChecked;
  final DateTime createdAt;

  ShoppingItem copyWith({
    bool? isChecked,
    ShoppingCategory? category,
  }) {
    return ShoppingItem(
      id: id,
      familyId: familyId,
      name: name,
      quantity: quantity,
      note: note,
      category: category ?? this.category,
      isChecked: isChecked ?? this.isChecked,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'familyId': familyId,
        'name': name,
        'quantity': quantity,
        'note': note,
        'category': category.name,
        'isChecked': isChecked,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ShoppingItem.fromJson(Map<String, Object?> json) {
    final String categoryName =
        json['category'] as String? ?? ShoppingCategory.other.name;
    return ShoppingItem(
      id: json['id'] as String? ?? '',
      familyId: json['familyId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      quantity: json['quantity'] as String? ?? '',
      note: json['note'] as String? ?? '',
      category: ShoppingCategory.values.firstWhere(
        (ShoppingCategory value) => value.name == categoryName,
        orElse: () => ShoppingCategory.other,
      ),
      isChecked: json['isChecked'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
