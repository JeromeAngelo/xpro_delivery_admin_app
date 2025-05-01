import 'package:xpro_delivery_admin_app/core/common/app/features/auth/domain/entity/auth_entity.dart';
import 'package:xpro_delivery_admin_app/core/enums/auth_roles_enum.dart';
import 'package:xpro_delivery_admin_app/core/typedefs/typedefs.dart';

class AuthModel extends AuthEntity {
  const AuthModel({
    super.id,
    super.collectionId,
    super.collectionName,
    super.email,
    super.profilePic,
    super.name,
    super.token,
    super.role,
    super.isActive,
    super.lastLogin,
    super.permissions,
  });

  const AuthModel.empty() : super.empty();

  AuthModel copyWith({
    String? id,
    String? collectionId,
    String? collectionName,
    String? email,
    String? profilePic,
    String? name,
    String? token,
    AdminRole? role,
    bool? isActive,
    DateTime? lastLogin,
    List<String>? permissions,
  }) {
    return AuthModel(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      email: email ?? this.email,
      profilePic: profilePic ?? this.profilePic,
      name: name ?? this.name,
      token: token ?? this.token,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      permissions: permissions ?? this.permissions,
    );
  }

  factory AuthModel.fromJson(DataMap json) {
    return AuthModel(
      id: json['id'] as String?,
      collectionId: json['collectionId'] as String?,
      collectionName: json['collectionName'] as String?,
      email: json['email'] as String?,
      profilePic: json['profilePic'] as String?,
      name: json['name'] as String?,
      token: json['token'] as String?,
      role: json['role'] != null 
          ? _parseRole(json['role']) 
          : null,
      isActive: json['isActive'] as bool? ?? true,
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin'] as String) 
          : null,
      permissions: json['permissions'] != null 
          ? List<String>.from(json['permissions'] as List) 
          : null,
    );
  }

  DataMap toJson() {
    return {
      'id': id,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'email': email,
      'profilePic': profilePic,
      'name': name,
      'token': token,
      'role': role?.name,
      'isActive': isActive,
      'lastLogin': lastLogin?.toIso8601String(),
      'permissions': permissions,
    };
  }

  factory AuthModel.fromEntity(AuthEntity entity) {
    return AuthModel(
      id: entity.id,
      collectionId: entity.collectionId,
      collectionName: entity.collectionName,
      email: entity.email,
      profilePic: entity.profilePic,
      name: entity.name,
      token: entity.token,
      role: entity.role,
      isActive: entity.isActive,
      lastLogin: entity.lastLogin,
      permissions: entity.permissions,
    );
  }

  static AdminRole _parseRole(dynamic roleValue) {
    if (roleValue is int) {
      return AdminRole.values[roleValue];
    } else if (roleValue is String) {
      return AdminRole.values.firstWhere(
        (role) => role.name == roleValue,
        orElse: () => AdminRole.viewer,
      );
    }
    return AdminRole.viewer;
  }
}
