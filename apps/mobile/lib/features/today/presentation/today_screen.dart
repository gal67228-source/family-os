import 'package:flutter/material.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/family_avatar_stack.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});
  @override
  Widget build(BuildContext context) => Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          appBar: AppBar(
              title:
                  Text('היום', style: Theme.of(context).textTheme.titleLarge),
              actions: const [
                Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: CircleAvatar(
                        radius: 17,
                        backgroundColor: Color(0xFFE9C4A9),
                        child: Icon(Icons.person_rounded, color: Colors.white)))
              ]),
          body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
              children: [
                Text('בוקר טוב, יוסי 👋',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const Text('שלישי, 21 במאי',
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 18),
                Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFFF2E6FF), Color(0xFFFFEEF6)]),
                        borderRadius: BorderRadius.circular(18)),
                    child: const Row(children: [
                      Text('🎂', style: TextStyle(fontSize: 28)),
                      SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text('מחכה יום ההולדת של שירה!',
                                style: TextStyle(fontWeight: FontWeight.w800)),
                            Text('אל תשכח לקנות מתנה 🎁')
                          ])),
                      Icon(Icons.chevron_left_rounded)
                    ])),
                const SizedBox(height: 18),
                const _Header('המשימות שלי'),
                const SizedBox(height: 10),
                const AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(children: [
                      _Task('להוציא את הזבל', 'היום', false),
                      Divider(height: 1),
                      _Task('לקנות חלב', 'היום', false),
                      Divider(height: 1),
                      _Task('להכין מצגת לעבודה', 'הושלם', true)
                    ])),
                const SizedBox(height: 18),
                Container(
                    decoration: BoxDecoration(
                        color: AppColors.softGreen,
                        borderRadius: BorderRadius.circular(18)),
                    child: Column(children: [
                      Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(children: [
                            const Icon(Icons.shopping_cart_rounded,
                                color: AppColors.secondary),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text('קניות שבועיות',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  const Text('18 מוצרים · 7 כבר נקנו')
                                ])),
                            const Text('🥦🍅🥕', style: TextStyle(fontSize: 24))
                          ])),
                      Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(18))),
                          child: const Text('המשך קנייה',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700)))
                    ])),
                const SizedBox(height: 18),
                const _Header('היום'),
                const SizedBox(height: 10),
                const AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(children: [
                      _Event(
                          '17:30', Icons.local_hospital_rounded, 'תור לרופא'),
                      Divider(height: 1),
                      _Event('19:00', Icons.sports_soccer_rounded, 'חוג כדורגל')
                    ]))
              ])));
}

class _Header extends StatelessWidget {
  const _Header(this.t);
  final String t;
  @override
  Widget build(BuildContext c) => Text(t,
      style: Theme.of(c)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w800));
}

class _Task extends StatelessWidget {
  const _Task(this.t, this.time, this.done);
  final String t, time;
  final bool done;
  @override
  Widget build(BuildContext c) => Padding(
      padding: const EdgeInsets.all(13),
      child: Row(children: [
        Icon(done ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: done ? AppColors.secondary : const Color(0xFFCBD5E1)),
        const SizedBox(width: 12),
        Expanded(
            child: Text(t,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    decoration: done ? TextDecoration.lineThrough : null))),
        Text(time,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(width: 8),
        const FamilyAvatarStack(count: 2, size: 24)
      ]));
}

class _Event extends StatelessWidget {
  const _Event(this.time, this.icon, this.t);
  final String time, t;
  final IconData icon;
  @override
  Widget build(BuildContext c) => Padding(
      padding: const EdgeInsets.all(13),
      child: Row(children: [
        SizedBox(
            width: 48,
            child: Text(time,
                style: const TextStyle(fontWeight: FontWeight.w800))),
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(t)),
        const FamilyAvatarStack(count: 2, size: 24)
      ]));
}
