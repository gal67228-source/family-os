import 'package:family_os/features/shopping/domain/shopping_category.dart';
import 'package:family_os/features/shopping/domain/voice_shopping_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses multiple Hebrew products and quantities', () {
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
}
