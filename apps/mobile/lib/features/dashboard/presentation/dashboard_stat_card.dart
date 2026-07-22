import 'package:flutter/material.dart';

class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.background,
    required this.foreground,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 20,
                backgroundColor: foreground.withValues(alpha: 0.12),
                child: Icon(icon, color: foreground),
              ),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: foreground,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
