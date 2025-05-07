import 'package:equatable/equatable.dart';

abstract class UserRolesEvent extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class GetAllUserRolesEvent extends UserRolesEvent{
  @override
  List<Object?> get props => [];
}
