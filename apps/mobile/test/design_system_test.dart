import 'package:family_os/core/widgets/app_button.dart';
import 'package:family_os/core/widgets/app_card.dart';
import 'package:family_os/core/widgets/state_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('primary button handles taps', (WidgetTester tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppPrimaryButton(
            label: 'שמור',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.tap(find.text('שמור'));
    expect(tapped, isTrue);
  });

  testWidgets('empty state renders inside app card',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppCard(
            child: EmptyState(
              icon: Icons.inbox_outlined,
              title: 'אין נתונים',
              message: 'עוד לא נוסף תוכן.',
            ),
          ),
        ),
      ),
    );
    expect(find.text('אין נתונים'), findsOneWidget);
    expect(find.text('עוד לא נוסף תוכן.'), findsOneWidget);
  });
}
