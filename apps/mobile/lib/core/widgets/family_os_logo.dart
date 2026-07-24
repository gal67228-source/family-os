import 'package:flutter/material.dart';

class FamilyOsLogo extends StatelessWidget {
  const FamilyOsLogo({
    this.size = 72,
    this.showShadow = false,
    super.key,
  });

  final double size;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.24),
        boxShadow: showShadow
            ? <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.24),
                  blurRadius: size * 0.22,
                  offset: Offset(0, size * 0.08),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/branding/family_os_icon.png',
        fit: BoxFit.cover,
      ),
    );
  }
}
