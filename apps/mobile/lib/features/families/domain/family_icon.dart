import 'package:flutter/material.dart';

abstract final class FamilyIcon {
  static const int family = 0;
  static const int home = 1;
  static const int favorite = 2;
  static const int pets = 3;

  static IconData fromId(int id) {
    switch (id) {
      case home:
        return Icons.home_rounded;
      case favorite:
        return Icons.favorite_rounded;
      case pets:
        return Icons.pets_rounded;
      default:
        return Icons.family_restroom_rounded;
    }
  }
}
