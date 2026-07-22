enum FamilyRole {
  admin,
  parent,
  child,
  guest,
}

extension FamilyRoleLabel on FamilyRole {
  String get label {
    switch (this) {
      case FamilyRole.admin:
        return 'Admin';
      case FamilyRole.parent:
        return 'הורה';
      case FamilyRole.child:
        return 'ילד/ה';
      case FamilyRole.guest:
        return 'אורח/ת';
    }
  }
}

class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final FamilyRole role;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
    };
  }

  factory FamilyMember.fromJson(Map<String, Object?> json) {
    final String roleName = json['role'] as String? ?? FamilyRole.guest.name;
    final FamilyRole role = FamilyRole.values.firstWhere(
      (FamilyRole value) => value.name == roleName,
      orElse: () => FamilyRole.guest,
    );

    return FamilyMember(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: role,
    );
  }
}
