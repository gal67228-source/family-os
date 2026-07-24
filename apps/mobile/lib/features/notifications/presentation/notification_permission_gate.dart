import 'package:flutter/material.dart';

import '../application/notification_service.dart';

class NotificationPermissionGate extends StatefulWidget {
  const NotificationPermissionGate({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<NotificationPermissionGate> createState() =>
      _NotificationPermissionGateState();
}

class _NotificationPermissionGateState
    extends State<NotificationPermissionGate> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermission();
    });
  }

  Future<void> _checkPermission() async {
    if (_checked || !mounted) {
      return;
    }
    _checked = true;

    try {
      await NotificationService.instance.initialize();
      final bool enabled =
          await NotificationService.instance.notificationsEnabled();

      if (enabled || !mounted) {
        return;
      }

      final bool? shouldRequest = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              icon: const Icon(
                Icons.notifications_active_rounded,
                size: 42,
              ),
              title: const Text('להפעיל התראות?'),
              content: const Text(
                'Family OS משתמש בהתראות כדי להזכיר על '
                'משימות, אירועים ומוצרים קבועים.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('לא עכשיו'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('הפעל התראות'),
                ),
              ],
            ),
          );
        },
      );

      if (shouldRequest != true || !mounted) {
        return;
      }

      final bool granted =
          await NotificationService.instance.requestPermissions();

      if (granted) {
        await NotificationService.instance.showTestNotification();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              granted
                  ? 'ההתראות הופעלו ונשלחה התראת בדיקה'
                  : 'ההרשאה לא אושרה. אפשר להפעיל אותה '
                      'מהגדרות הטלפון.',
            ),
          ),
        );
      }
    } catch (_) {
      // Permission setup must not affect the rest of the application.
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
