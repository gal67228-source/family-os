import 'package:family_os/features/shopping/domain/shopping_category.dart';
import 'package:family_os/features/shopping/domain/voice_shopping_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses products separated by commas and conjunctions', () {
    final List<VoiceShoppingDraft> items = VoiceShoppingParser.parse(
      'חלב, שתי גבינות, 6 ביצים ולחם',
    );

    expect(items, hasLength(4));
    expect(items[0].name, 'חלב');
    expect(items[0].category, ShoppingCategory.dairy);
    expect(items[1].quantity, '2');
    expect(items[1].category, ShoppingCategory.cheese);
    expect(items[2].quantity, '6');
    expect(items[2].category, ShoppingCategory.eggs);
    expect(items[3].category, ShoppingCategory.bakery);
  });

  test('separates consecutive known products without delimiters', () {
    final List<VoiceShoppingDraft> items =
        VoiceShoppingParser.parse('חלב טונה גבינה');

    expect(items, hasLength(3));
    expect(items.map((VoiceShoppingDraft item) => item.name), <String>[
      'חלב',
      'טונה',
      'גבינה',
    ]);
    expect(items[0].category, ShoppingCategory.dairy);
    expect(items[1].category, ShoppingCategory.canned);
    expect(items[2].category, ShoppingCategory.cheese);
  });

  test('keeps multi-word products and quantities together', () {
    final List<VoiceShoppingDraft> items = VoiceShoppingParser.parse(
      '2 חלב 6 ביצים גבינה צהובה קוטג עגבניות',
    );

    expect(items, hasLength(5));
    expect(items[0].name, 'חלב');
    expect(items[0].quantity, '2');
    expect(items[1].name, 'ביצים');
    expect(items[1].quantity, '6');
    expect(items[2].name, 'גבינה צהובה');
    expect(items[2].category, ShoppingCategory.cheese);
    expect(items[3].name, 'קוטג');
    expect(items[4].name, 'עגבניות');
    expect(items[4].category, ShoppingCategory.vegetables);
  });

  test('preserves unknown consecutive words as separate products', () {
    final List<VoiceShoppingDraft> items =
        VoiceShoppingParser.parse('מוצרחדש מוצרנוסף');

    expect(items, hasLength(2));
    expect(items[0].name, 'מוצרחדש');
    expect(items[1].name, 'מוצרנוסף');
  });
}
