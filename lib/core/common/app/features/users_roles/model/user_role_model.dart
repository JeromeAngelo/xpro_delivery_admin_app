

import 'package:xpro_delivery_admin_app/core/common/app/features/users_roles/entity/user_role_entity.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

class UserRoleModel extends UserRoleEntity {
  final String pocketbaseId;

  const UserRoleModel({
    super.id,
    super.name,
    super.permissions,
    String? pocketbaseId,
  }) : pocketbaseId = pocketbaseId ?? id ?? '';

  factory UserRoleModel.fromJson(DataMap json) {
    return UserRoleModel(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      permissions: (json['permissions'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      pocketbaseId: json['id']?.toString(),
    );
  }

  DataMap toJson() {
    return {
      'id': pocketbaseId,
      'name': name,
      'permissions': permissions,
    };
  }

  UserRoleModel copyWith({
    String? id,
    String? name,
    List<String>? permissions,
  }) {
    return UserRoleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      permissions: permissions ?? this.permissions,
      pocketbaseId: id ?? pocketbaseId,
    );
  }
}
