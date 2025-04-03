import 'package:desktop_app/core/enums/auth_roles_enum.dart';
import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? id;
  final String? collectionId;
  final String? collectionName;
  final String? email;
  final String? profilePic;
  final String? name;
  final String? token;
  final AdminRole? role;
  final bool isActive;
  final DateTime? lastLogin;
  final List<String>? permissions;

  const AuthEntity({
    this.id,
    this.collectionId,
    this.collectionName,
    this.email,
    this.profilePic,
    this.name,
    this.token,
    this.role,
    this.isActive = true,
    this.lastLogin,
    this.permissions,
  });

  const AuthEntity.empty()
    : id = '',
      collectionId = '',
      collectionName = '',
      email = '',
      profilePic = '',
      token = '',
      name = '',
      role = AdminRole.viewer,
      isActive = false,
      lastLogin = null,
      permissions = const [];

  @override
  List<Object?> get props => [
    id,
    collectionId,
    collectionName,
    email,
    profilePic,
    name,
    token,
    role,
    isActive,
    lastLogin,
    permissions,
  ];
}
