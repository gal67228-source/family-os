import 'family_member.dart';

class FamilyWorkspace {
  const FamilyWorkspace({
    required this.id,
    required this.name,
    required this.iconId,
    required this.colorValue,
    required this.inviteCode,
    required this.members,
  });

  final String id;
  final String name;
  final int iconId;
  final int colorValue;
  final String inviteCode;
  final List<FamilyMember> members;

  FamilyWorkspace copyWith({
    String? name,
    int? iconId,
    int? colorValue,
    String? inviteCode,
    List<FamilyMember>? members,
  }) {
    return FamilyWorkspace(
      id: id,
      name: name ?? this.name,
      iconId: iconId ?? this.iconId,
      colorValue: colorValue ?? this.colorValue,
      inviteCode: inviteCode ?? this.inviteCode,
      members: members ?? this.members,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'iconId': iconId,
      'colorValue': colorValue,
      'inviteCode': inviteCode,
      'members': members.map((FamilyMember member) => member.toJson()).toList(),
    };
  }

  factory FamilyWorkspace.fromJson(Map<String, Object?> json) {
    final List<Object?> rawMembers =
        json['members'] as List<Object?>? ?? <Object?>[];

    return FamilyWorkspace(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      iconId: json['iconId'] as int? ?? 0,
      colorValue: json['colorValue'] as int? ?? 0xFF1256E8,
      inviteCode: json['inviteCode'] as String? ?? '',
      members: rawMembers
          .whereType<Map<String, Object?>>()
          .map(FamilyMember.fromJson)
          .toList(),
    );
  }
}
