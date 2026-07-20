import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/section_card.dart';
import '../../families/application/family_controller.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FamilyState familyState = ref.watch(familyControllerProvider);
    final String familyName =
        familyState.selectedFamily?.name ?? 'המשפחה שלי';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.push('/family/switch'),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(familyName),
                  const SizedBox(width: 4),
                  const Icon(Icons.expand_more_rounded),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () {},
              tooltip: 'התראות',
              icon: const Icon(Icons.notifications_none_rounded),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 112),
          children: <Widget>[
            Text(
              'בוקר טוב 👋',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'כל מה שחשוב למשפחה, במקום אחד.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            SectionCard(
              title: 'הכי חשוב עכשיו',
              icon: Icons.auto_awesome_rounded,
              child: Text(
                'יש לך 2 משימות להיום ו־12 מוצרים ברשימת הקניות.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 14),
            const SectionCard(
              title: 'המשימות שלי',
              icon: Icons.task_alt_rounded,
              child: Column(
                children: <Widget>[
                  CheckboxListTile(
                    value: false,
                    onChanged: null,
                    title: Text('להוציא את הזבל'),
                    subtitle: Text('היום'),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    value: false,
                    onChanged: null,
                    title: Text('לקבוע תור לרופא'),
                    subtitle: Text('משימה פרטית'),
                    secondary: Icon(Icons.lock_outline_rounded),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const SectionCard(
              title: 'קניות שבועיות',
              icon: Icons.shopping_cart_rounded,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('12 מוצרים נשארו'),
                subtitle: Text('5 מוצרים כבר נאספו'),
                trailing: Icon(Icons.chevron_left_rounded),
              ),
            ),
            const SizedBox(height: 14),
            const SectionCard(
              title: 'היום ביומן',
              icon: Icons.calendar_month_rounded,
              child: Column(
                children: <Widget>[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(child: Text('17')),
                    title: Text('תור לרופא'),
                    subtitle: Text('17:30'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(child: Text('19')),
                    title: Text('חוג כדורגל'),
                    subtitle: Text('19:00'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
