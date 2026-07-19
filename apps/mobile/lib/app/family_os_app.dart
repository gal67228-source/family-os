import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';

class FamilyOsApp extends StatelessWidget {
  const FamilyOsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Family OS',
      locale: const Locale('he'),
      supportedLocales: const <Locale>[
        Locale('he'),
        Locale('en'),
      ],
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
