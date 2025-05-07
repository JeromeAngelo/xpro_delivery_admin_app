import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_roles/presentation/bloc/bloc/user_roles_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_roles/presentation/bloc/bloc/user_roles_state.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/users_roles/domain/usecases/get_all_roles_usecase.dart';

class UserRolesBloc extends Bloc<UserRolesEvent, UserRolesState> {
  final GetAllRolesUsecase _getAllUserRoles;

  UserRolesBloc({required GetAllRolesUsecase getAllUserRoles})
    : _getAllUserRoles = getAllUserRoles,
      super(UserRolesInitial()) {
    on<GetAllUserRolesEvent>(_getAllUserRolesHandler);
  }

  Future<void> _getAllUserRolesHandler(
    GetAllUserRolesEvent event,
    Emitter<UserRolesState> state,
  ) async {
    emit(UserRolesLoading());

    final result = await _getAllUserRoles();

    result.fold(
      (failure) {
        emit(UserRolesErrors(message: failure.message));
      },
      (userRoles) {
        emit(AllUsersLoaded(userRoles: userRoles));
      },
    );
  }
}
