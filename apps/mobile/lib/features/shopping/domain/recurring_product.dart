import 'shopping_category.dart';

enum RecurrenceCadence {
  weekly,
  biweekly,
  monthly,
}

extension RecurrenceCadenceLabel on RecurrenceCadence {
  String get label {
    switch (this) {
      case RecurrenceCadence.weekly:
        return 'שבועי';
      case RecurrenceCadence.biweekly:
        return 'דו-שבועי';
      case RecurrenceCadence.monthly:
        return 'חודשי';
    }
  }

  Duration get duration {
    switch (this) {
      case RecurrenceCadence.weekly:
        return const Duration(days: 7);
      case RecurrenceCadence.biweekly:
        return const Duration(days: 14);
      case RecurrenceCadence.monthly:
        return const Duration(days: 30);
    }
  }
}

class RecurringProduct {
  const RecurringProduct({
    required this.id,
    required this.familyId,
    required this.name,
    required this.quantity,
    required this.category,
    required this.cadence,
    required this.lastAddedAt,
  });

  final String id;
  final String familyId;
  final String name;
  final String quantity;
  final ShoppingCategory category;
  final RecurrenceCadence cadence;
  final DateTime? lastAddedAt;

  bool get isDue {
    if (lastAddedAt == null) {
      return true;
    }
    return DateTime.now().difference(lastAddedAt!) >= cadence.duration;
  }

  RecurringProduct copyWith({DateTime? lastAddedAt}) {
    return RecurringProduct(
      id: id,
      familyId: familyId,
      name: name,
      quantity: quantity,
      category: category,
      cadence: cadence,
      lastAddedAt: lastAddedAt ?? this.lastAddedAt,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'familyId': familyId,
        'name': name,
        'quantity': quantity,
        'category': category.name,
        'cadence': cadence.name,
        'lastAddedAt': lastAddedAt?.toIso8601String(),
      };

  factory RecurringProduct.fromJson(Map<String, Object?> json) {
    final String categoryName =
        json['category'] as String? ?? ShoppingCategory.other.name;
    final String cadenceName =
        json['cadence'] as String? ?? RecurrenceCadence.weekly.name;
    return RecurringProduct(
      id: json['id'] as String? ?? '',
      familyId: json['familyId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      quantity: json['quantity'] as String? ?? '',
      category: ShoppingCategory.values.firstWhere(
        (ShoppingCategory value) => value.name == categoryName,
        orElse: () => ShoppingCategory.other,
      ),
      cadence: RecurrenceCadence.values.firstWhere(
        (RecurrenceCadence value) => value.name == cadenceName,
        orElse: () => RecurrenceCadence.weekly,
      ),
      lastAddedAt: DateTime.tryParse(
        json['lastAddedAt'] as String? ?? '',
      ),
    );
  }
}
