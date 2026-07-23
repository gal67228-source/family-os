import 'shopping_category.dart';

enum RecurrenceCadence { weekly, biweekly, monthly }

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

  DateTime nextDate(DateTime from) {
    switch (this) {
      case RecurrenceCadence.weekly:
        return from.add(const Duration(days: 7));
      case RecurrenceCadence.biweekly:
        return from.add(const Duration(days: 14));
      case RecurrenceCadence.monthly:
        final int nextMonth = from.month == 12 ? 1 : from.month + 1;
        final int nextYear = from.month == 12 ? from.year + 1 : from.year;
        final int lastDay = DateTime(nextYear, nextMonth + 1, 0).day;
        final int day = from.day > lastDay ? lastDay : from.day;
        return DateTime(nextYear, nextMonth, day);
    }
  }
}

class RecurringProduct {
  const RecurringProduct({
    required this.id,
    required this.familyId,
    required this.listId,
    required this.name,
    required this.quantity,
    required this.category,
    required this.cadence,
    required this.autoAdd,
    required this.lastAddedAt,
  });

  final String id;
  final String familyId;
  final String listId;
  final String name;
  final String quantity;
  final ShoppingCategory category;
  final RecurrenceCadence cadence;
  final bool autoAdd;
  final DateTime? lastAddedAt;

  bool get isDue {
    if (lastAddedAt == null) return true;
    return !DateTime.now().isBefore(cadence.nextDate(lastAddedAt!));
  }

  RecurringProduct copyWith({
    String? listId,
    bool? autoAdd,
    DateTime? lastAddedAt,
  }) {
    return RecurringProduct(
      id: id,
      familyId: familyId,
      listId: listId ?? this.listId,
      name: name,
      quantity: quantity,
      category: category,
      cadence: cadence,
      autoAdd: autoAdd ?? this.autoAdd,
      lastAddedAt: lastAddedAt ?? this.lastAddedAt,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'familyId': familyId,
        'listId': listId,
        'name': name,
        'quantity': quantity,
        'category': category.name,
        'cadence': cadence.name,
        'autoAdd': autoAdd,
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
      listId: json['listId'] as String? ?? '',
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
      autoAdd: json['autoAdd'] as bool? ?? true,
      lastAddedAt: DateTime.tryParse(json['lastAddedAt'] as String? ?? ''),
    );
  }
}
