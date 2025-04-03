import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignInEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class GetAuthTokenEvent extends AuthEvent {
  const GetAuthTokenEvent();
}

class GetAllUsersEvent extends AuthEvent {
  const GetAllUsersEvent();
}

class GetUserByIdEvent extends AuthEvent {
  final String userId;

  const GetUserByIdEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AuthInitialEvent extends AuthEvent {
  const AuthInitialEvent();
}
