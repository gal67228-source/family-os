import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _email = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final bool success =
        await ref.read(authControllerProvider.notifier).sendPasswordReset(
              _email.text,
            );
    if (success && mounted) {
      setState(() {
        _sent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthState state = ref.watch(authControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('שחזור סיסמה')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            const Icon(Icons.mark_email_read_outlined, size: 64),
            const SizedBox(height: 18),
            Text(
              'נשלח אליך קישור לאיפוס הסיסמה',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'כתובת מייל',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            if (state.errorMessage != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                state.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (_sent) ...<Widget>[
              const SizedBox(height: 12),
              const Text(
                'הקישור נשלח. בדוק את תיבת הדואר.',
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: state.isLoading ? null : _send,
              child: const Text('שלח קישור'),
            ),
          ],
        ),
      ),
    );
  }
}
