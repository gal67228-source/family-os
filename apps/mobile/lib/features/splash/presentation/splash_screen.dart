import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircleAvatar(
                radius: 38,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(
                  Icons.home_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'FamilyWorkspace OS',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text('הבית שלך. מסודר.'),
              const SizedBox(height: 22),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
