import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/entity/users_entity.dart';
import 'package:equatable/equatable.dart';

abstract class GeneralUserState extends Equatable {
  const GeneralUserState();

  @override
  List<Object> get props => [];
}

class GeneralUserInitial extends GeneralUserState {}

class GeneralUserLoading extends GeneralUserState {}

class AllUsersLoaded extends GeneralUserState {
  final List<GeneralUserEntity> users;
  
  const AllUsersLoaded(this.users);
  
  @override
  List<Object> get props => [users];
}

class UserCreated extends GeneralUserState {
  final GeneralUserEntity user;
  
  const UserCreated(this.user);
  
  @override
  List<Object> get props => [user];
}

class UserUpdated extends GeneralUserState {
  final GeneralUserEntity user;
  
  const UserUpdated(this.user);
  
  @override
  List<Object> get props => [user];
}

class UserDeleted extends GeneralUserState {
  final String userId;
  
  const UserDeleted(this.userId);
  
  @override
  List<Object> get props => [userId];
}

class AllUsersDeleted extends GeneralUserState {}

class GeneralUserError extends GeneralUserState {
  final String message;
  
  const GeneralUserError(this.message);
  
  @override
  List<Object> get props => [message];
}
