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
  await NotificationService.instance.initialize(
    onOpenRoute: appRouter.go,
  );
  runApp(const ProviderScope(child: FamilyOsApp()));
}
