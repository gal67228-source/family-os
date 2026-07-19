import 'package:family_os/app/family_os_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the Today screen', (WidgetTester tester) async {
    await tester.pumpWidget(const FamilyOsApp());
    await tester.pumpAndSettle();

    expect(find.text('משפחת כהן'), findsOneWidget);
    expect(find.text('המשימות שלי'), findsOneWidget);
  });
}
