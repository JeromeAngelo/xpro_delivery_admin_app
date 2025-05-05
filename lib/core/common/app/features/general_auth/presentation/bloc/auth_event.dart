import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/entity/users_entity.dart';
import 'package:equatable/equatable.dart';

abstract class GeneralUserEvent extends Equatable {
  const GeneralUserEvent();
}

class GetAllUsersEvent extends GeneralUserEvent {
  const GetAllUsersEvent();
  
  @override
  List<Object?> get props => [];
}

class UserSignInEvent extends  GeneralUserEvent{
  final String email;
  final String password;

  const UserSignInEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class UserSignOutEvent extends GeneralUserEvent {
  const UserSignOutEvent();
  
  @override
  // TODO: implement props
  List<Object?> get props => [];
}


class CreateUserEvent extends GeneralUserEvent {
  final GeneralUserEntity user;
  
  const CreateUserEvent(this.user);
  
  @override
  List<Object?> get props => [user];
}

class UpdateUserEvent extends GeneralUserEvent {
  final GeneralUserEntity user;
  
  const UpdateUserEvent(this.user);
  
  @override
  List<Object?> get props => [user];
}

class DeleteUserEvent extends GeneralUserEvent {
  final String userId;
  
  const DeleteUserEvent(this.userId);
  
  @override
  List<Object?> get props => [userId];
}

class DeleteAllUsersEvent extends GeneralUserEvent {
  const DeleteAllUsersEvent();
  
  @override
  List<Object?> get props => [];
}
