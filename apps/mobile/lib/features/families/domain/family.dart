import '../../auth/domain/app_user.dart';

class Family {
  const Family({
    required this.id,
    required this.name,
    required this.role,
  });

  final String id;
  final String name;
  final UserRole role;
}
