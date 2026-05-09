import 'package:json_annotation/json_annotation.dart';

/// Mirrors Postgres `user_role` enum and Edge Function `role` strings.
enum UserRole {
  superAdmin('super_admin'),
  buildingAdmin('building_admin'),
  buildingCoAdmin('building_co_admin'),
  accountant('accountant'),
  resident('resident'),
  owner('owner');

  const UserRole(this.wireValue);

  final String wireValue;

  static UserRole fromWire(String raw) {
    final cleaned = raw.trim();
    for (final role in UserRole.values) {
      if (role.wireValue == cleaned) {
        return role;
      }
    }
    return UserRole.resident;
  }
}

/// Mirrors Postgres `invite_code_type`.
enum InviteCodeType {
  admin,
  unit;

  static InviteCodeType fromWire(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'admin':
        return InviteCodeType.admin;
      case 'unit':
        return InviteCodeType.unit;
      default:
        return InviteCodeType.unit;
    }
  }
}

/// JSON wire string ↔ UserRole for persisted local session.
class UserRoleConverter implements JsonConverter<UserRole, String> {
  const UserRoleConverter();

  @override
  UserRole fromJson(String json) => UserRole.fromWire(json);

  @override
  String toJson(UserRole object) => object.wireValue;
}
