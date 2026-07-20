import 'package:flutter/material.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/widgets/app_card.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});
  @override
  State<ShoppingScreen> createState() => _S();
}

class _S extends State<ShoppingScreen> {
  final checked = <int>{0, 1};
  final items = ['חלב', 'לחם', 'ביצים', 'בננות', 'עגבניות'];
  @override
  Widget build(BuildContext c) => Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          appBar: AppBar(
              title: Text('קניות', style: Theme.of(c).textTheme.titleLarge),
              actions: [
                IconButton(
                    onPressed: () {}, icon: const Icon(Icons.menu_rounded))
              ]),
          body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
              children: [
                Row(children: [
                  Expanded(
                      child: ChoiceChip(
                          label: const Center(child: Text('רשימות')),
                          selected: true,
                          onSelected: (_) {},
                          selectedColor: AppColors.primary,
                          labelStyle: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700),
                          side: BorderSide.none)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: ChoiceChip(
                          label: const Center(child: Text('מוצרים קבועים')),
                          selected: false,
                          onSelected: (_) {},
                          side: BorderSide.none))
                ]),
                const SizedBox(height: 18),
                AppCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Row(children: [
                        const Icon(Icons.shopping_cart_rounded,
                            color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text('קניות שבועיות',
                                style: Theme.of(c)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800))),
                        const Icon(Icons.more_vert_rounded)
                      ]),
                      const SizedBox(height: 10),
                      const LinearProgressIndicator(
                          value: .38,
                          minHeight: 5,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          backgroundColor: Color(0xFFE4EAF4),
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.secondary)),
                      const SizedBox(height: 6),
                      const Text('7 מתוך 18 מוצרים'),
                      const SizedBox(height: 12),
                      for (int i = 0; i < items.length; i++)
                        CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            value: checked.contains(i),
                            activeColor: AppColors.secondary,
                            title: Text(items[i],
                                style: TextStyle(
                                    decoration: checked.contains(i)
                                        ? TextDecoration.lineThrough
                                        : null)),
                            onChanged: (v) => setState(() {
                                  if (v ?? false) {
                                    checked.add(i);
                                  } else {
                                    checked.remove(i);
                                  }
                                })),
                      TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('הוסף מוצר'))
                    ]))
              ])));
}
