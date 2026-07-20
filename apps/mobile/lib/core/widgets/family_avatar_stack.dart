import 'package:flutter/material.dart';

class FamilyAvatarStack extends StatelessWidget {
  const FamilyAvatarStack({this.count = 3, this.size = 26, super.key});
  final int count;
  final double size;
  @override
  Widget build(BuildContext context) {
    final colors = <Color>[
      const Color(0xFFF5C7A9),
      const Color(0xFFAEC9F8),
      const Color(0xFFC8E9B5)
    ];
    return SizedBox(
        width: size + ((count - 1) * (size * .58)),
        height: size,
        child: Stack(
            children: List.generate(
                count,
                (i) => Positioned(
                    left: i * (size * .58),
                    child: CircleAvatar(
                        radius: size / 2,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                            radius: size / 2 - 2,
                            backgroundColor: colors[i % colors.length],
                            child: Icon(Icons.person_rounded,
                                size: size * .58, color: Colors.white)))))));
  }
}
