import '../../auth/domain/app_user.dart';

class FamilyWorkspace {
  const FamilyWorkspace({
    required this.id,
    required this.name,
    required this.role,
  });

  final String id;
  final String name;
  final UserRole role;
}
