import 'shopping_category.dart';

class ProductCategoryPreference {
  const ProductCategoryPreference({
    required this.productName,
    required this.category,
  });

  final String productName;
  final ShoppingCategory category;

  Map<String, Object?> toJson() => <String, Object?>{
        'productName': productName,
        'category': category.name,
      };

  factory ProductCategoryPreference.fromJson(
    Map<String, Object?> json,
  ) {
    final String categoryName =
        json['category'] as String? ?? ShoppingCategory.other.name;
    return ProductCategoryPreference(
      productName: json['productName'] as String? ?? '',
      category: ShoppingCategory.values.firstWhere(
        (ShoppingCategory value) => value.name == categoryName,
        orElse: () => ShoppingCategory.other,
      ),
    );
  }
}
