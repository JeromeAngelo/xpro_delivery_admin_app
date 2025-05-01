import 'package:bloc/bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/usecases/create_users.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/usecases/delete_all_users.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/usecases/delete_users.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/usecases/get_all_users.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/usecases/update_users.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';

class GeneralUserBloc extends Bloc<GeneralUserEvent, GeneralUserState> {
  final GetAllUsers _getAllUsers;
  final CreateUser _createUser;
  final UpdateUser _updateUser;
  final DeleteUser _deleteUser;
  final DeleteAllUsers _deleteAllUsers;

  GeneralUserBloc({
    required GetAllUsers getAllUsers,
    required CreateUser createUser,
    required UpdateUser updateUser,
    required DeleteUser deleteUser,
    required DeleteAllUsers deleteAllUsers,
  })  : _getAllUsers = getAllUsers,
        _createUser = createUser,
        _updateUser = updateUser,
        _deleteUser = deleteUser,
        _deleteAllUsers = deleteAllUsers,
        super(GeneralUserInitial()) {
    on<GetAllUsersEvent>(_onGetAllUsers);
    on<CreateUserEvent>(_onCreateUser);
    on<UpdateUserEvent>(_onUpdateUser);
    on<DeleteUserEvent>(_onDeleteUser);
    on<DeleteAllUsersEvent>(_onDeleteAllUsers);
  }

  Future<void> _onGetAllUsers(
    GetAllUsersEvent event,
    Emitter<GeneralUserState> emit,
  ) async {
    debugPrint('🔄 BLOC: Fetching all users');
    emit(GeneralUserLoading());

    final result = await _getAllUsers();
    result.fold(
      (failure) {
        debugPrint('❌ BLOC: Failed to get all users: ${failure.message}');
        emit(GeneralUserError(failure.message));
      },
      (users) {
        debugPrint('✅ BLOC: Successfully retrieved ${users.length} users');
        emit(AllUsersLoaded(users));
      },
    );
  }

  Future<void> _onCreateUser(
    CreateUserEvent event,
    Emitter<GeneralUserState> emit,
  ) async {
    debugPrint('🔄 BLOC: Creating new user');
    emit(GeneralUserLoading());

    final result = await _createUser(event.user);
    result.fold(
      (failure) {
        debugPrint('❌ BLOC: Failed to create user: ${failure.message}');
        emit(GeneralUserError(failure.message));
      },
      (user) {
        debugPrint('✅ BLOC: User created successfully: ${user.id}');
        emit(UserCreated(user));
        // Refresh the list
        add(const GetAllUsersEvent());
      },
    );
  }

  Future<void> _onUpdateUser(
    UpdateUserEvent event,
    Emitter<GeneralUserState> emit,
  ) async {
    debugPrint('🔄 BLOC: Updating user: ${event.user.id}');
    emit(GeneralUserLoading());

    final result = await _updateUser(event.user);
    result.fold(
      (failure) {
        debugPrint('❌ BLOC: Failed to update user: ${failure.message}');
        emit(GeneralUserError(failure.message));
      },
      (user) {
        debugPrint('✅ BLOC: User updated successfully');
        emit(UserUpdated(user));
        // Refresh the list
        add(const GetAllUsersEvent());
      },
    );
  }

  Future<void> _onDeleteUser(
    DeleteUserEvent event,
    Emitter<GeneralUserState> emit,
  ) async {
    debugPrint('🔄 BLOC: Deleting user: ${event.userId}');
    emit(GeneralUserLoading());

    final result = await _deleteUser(event.userId);
    result.fold(
      (failure) {
        debugPrint('❌ BLOC: Failed to delete user: ${failure.message}');
        emit(GeneralUserError(failure.message));
      },
      (_) {
        debugPrint('✅ BLOC: User deleted successfully');
        emit(UserDeleted(event.userId));
        // Refresh the list
        add(const GetAllUsersEvent());
      },
    );
  }

  Future<void> _onDeleteAllUsers(
    DeleteAllUsersEvent event,
    Emitter<GeneralUserState> emit,
  ) async {
    debugPrint('🔄 BLOC: Deleting all users');
    emit(GeneralUserLoading());

    final result = await _deleteAllUsers();
    result.fold(
      (failure) {
        debugPrint('❌ BLOC: Failed to delete all users: ${failure.message}');
        emit(GeneralUserError(failure.message));
      },
      (_) {
        debugPrint('✅ BLOC: All users deleted successfully');
        emit(AllUsersDeleted());
        // Refresh to show empty list
        add(const GetAllUsersEvent());
      },
    );
  }
}
