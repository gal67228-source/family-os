import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/family_os_app.dart';
import 'app/router.dart';
import 'features/notifications/application/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  runApp(const ProviderScope(child: FamilyOsApp()));

  unawaited(
    NotificationService.instance
        .initialize(onOpenRoute: appRouter.go)
        .timeout(const Duration(seconds: 4))
        .then((_) async {
      await Future<void>.delayed(
        const Duration(milliseconds: 900),
      );
      await NotificationService.instance.requestPermissions();
    }).catchError((Object _) {}),
  );
}
