import 'package:family_os/app/family_os_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the authentication flow without framework exceptions',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FamilyOsApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 750));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('ברוכים הבאים'), findsOneWidget);
    expect(find.text('פתיחת חשבון חדש'), findsOneWidget);
  });
}
