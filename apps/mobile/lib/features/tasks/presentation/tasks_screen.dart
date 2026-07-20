import 'package:flutter/material.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/family_avatar_stack.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override
  State<TasksScreen> createState() => _S();
}

class _S extends State<TasksScreen> {
  int f = 0;
  @override
  Widget build(BuildContext c) => Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          appBar: AppBar(
              title:
                  Text('המשימות שלי', style: Theme.of(c).textTheme.titleLarge),
              actions: [
                IconButton(
                    onPressed: () {}, icon: const Icon(Icons.menu_rounded))
              ]),
          body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
              children: [
                Row(
                    children: List.generate(4, (i) {
                  final l = ['הכל', 'היום', 'הושלמו', 'פרטיות'];
                  return Expanded(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: ChoiceChip(
                              label: Center(child: Text(l[i])),
                              selected: f == i,
                              onSelected: (_) => setState(() => f = i),
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                  color: f == i
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w700),
                              side: BorderSide.none)));
                })),
                const SizedBox(height: 20),
                const _G('היום'),
                const SizedBox(height: 10),
                const AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(children: [
                      _T('להוציא את הזבל', 'גבוה', AppColors.error, 2),
                      Divider(height: 1),
                      _T('לקנות חלב', 'בינוני', AppColors.warning, 3)
                    ])),
                const SizedBox(height: 20),
                const _G('מחר'),
                const SizedBox(height: 10),
                const AppCard(
                    padding: EdgeInsets.zero,
                    child:
                        _T('לשלוח דוח לעבודה', 'בינוני', AppColors.warning, 2)),
                const SizedBox(height: 20),
                const _G('שבוע הבא'),
                const SizedBox(height: 10),
                const AppCard(
                    padding: EdgeInsets.zero,
                    child: _T('לצבוע את החדר', 'נמוך', AppColors.info, 2))
              ])));
}

class _G extends StatelessWidget {
  const _G(this.t);
  final String t;
  @override
  Widget build(BuildContext c) => Text(t,
      style: Theme.of(c)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w800));
}

class _T extends StatelessWidget {
  const _T(this.t, this.p, this.color, this.n);
  final String t, p;
  final Color color;
  final int n;
  @override
  Widget build(BuildContext c) => Padding(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        const Icon(Icons.circle_outlined, color: Color(0xFFCBD5E1)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(p,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w800))
        ])),
        FamilyAvatarStack(count: n, size: 24)
      ]));
}
