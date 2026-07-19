import 'package:family_os/app/family_os_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the Today screen without framework exceptions',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FamilyOsApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('משפחת כהן'), findsOneWidget);
    expect(find.text('המשימות שלי'), findsOneWidget);
  });
}
