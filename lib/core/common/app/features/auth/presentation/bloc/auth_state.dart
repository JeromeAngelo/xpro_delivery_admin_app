import 'package:equatable/equatable.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/auth/domain/entity/auth_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final AuthEntity user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class TokenLoaded extends AuthState {
  final String? token;

  const TokenLoaded(this.token);

  @override
  List<Object?> get props => [token];
}

class UsersLoaded extends AuthState {
  final List<AuthEntity> users;

  const UsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class UserLoaded extends AuthState {
  final AuthEntity user;

  const UserLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class SignOutSuccess extends AuthState {
  const SignOutSuccess();
}
