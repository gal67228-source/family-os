import 'package:flutter/material.dart';

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('קניות'),
          actions: <Widget>[
            IconButton(
              onPressed: () {},
              tooltip: 'הוסף בקול',
              icon: const Icon(Icons.mic_rounded),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 112),
          children: <Widget>[
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.shopping_cart_checkout_rounded),
              label: const Text('התחל מצב קנייה'),
            ),
            const SizedBox(height: 16),
            Text(
              'ירקות ופירות',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const CheckboxListTile(
              value: false,
              onChanged: null,
              title: Text('עגבניות'),
              subtitle: Text('1 ק״ג'),
            ),
            const CheckboxListTile(
              value: true,
              onChanged: null,
              title: Text('מלפפונים'),
              subtitle: Text('6 יחידות'),
            ),
            const SizedBox(height: 12),
            Text(
              'מוצרי חלב',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const CheckboxListTile(
              value: false,
              onChanged: null,
              title: Text('חלב'),
              subtitle: Text('2 יחידות'),
            ),
          ],
        ),
      ),
    );
  }
}
