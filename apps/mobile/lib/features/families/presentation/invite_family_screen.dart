import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InviteFamilyScreen extends StatefulWidget {
  const InviteFamilyScreen({super.key});

  @override
  State<InviteFamilyScreen> createState() => _InviteFamilyScreenState();
}

class _InviteFamilyScreenState extends State<InviteFamilyScreen> {
  final TextEditingController _email = TextEditingController();
  final List<String> _invited = <String>[];

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _addInvite() {
    final String value = _email.text.trim();
    if (value.contains('@') && !_invited.contains(value)) {
      setState(() {
        _invited.add(value);
        _email.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('הזמנת בני משפחה')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            Text(
              'הזמן בני משפחה',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'אפשר לדלג ולהזמין משתמשים גם מאוחר יותר.',
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'כתובת מייל',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: _addInvite,
                  tooltip: 'הוסף הזמנה',
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            const SizedBox(height: 14),
            for (final String email in _invited)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.mark_email_read_outlined),
                  title: Text(email),
                  trailing: IconButton(
                    onPressed: () {
                      setState(() {
                        _invited.remove(email);
                      });
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/today'),
              child: const Text('המשך לאפליקציה'),
            ),
            TextButton(
              onPressed: () => context.go('/today'),
              child: const Text('דלג כרגע'),
            ),
          ],
        ),
      ),
    );
  }
}
