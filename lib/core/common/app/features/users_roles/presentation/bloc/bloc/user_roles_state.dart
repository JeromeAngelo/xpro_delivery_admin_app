import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_roles/domain/entity/user_role_entity.dart';

abstract class UserRolesState extends Equatable {}

class UserRolesInitial extends UserRolesState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class UserRolesLoading extends UserRolesState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class AllUsersLoaded extends UserRolesState {
  final List<UserRoleEntity> userRoles;

  AllUsersLoaded({required this.userRoles});
  @override
  // TODO: implement props
  List<Object?> get props => [userRoles];
}

class UserRolesErrors extends UserRolesState {
  final String message;

  UserRolesErrors({required this.message});

  @override
  // TODO: implement props
  List<Object?> get props => [message];
}
