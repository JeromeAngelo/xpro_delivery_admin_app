import 'package:bloc/bloc.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/usecases/create_users.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/usecases/delete_all_users.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/usecases/delete_users.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/usecases/get_all_users.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/usecases/get_user_by_id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/usecases/sign_in.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/usecases/sign_out.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/domain/usecases/update_users.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/general_auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';

class GeneralUserBloc extends Bloc<GeneralUserEvent, GeneralUserState> {
  final GetAllUsers _getAllUsers;
  final GetUserById _getUserById;

  final CreateUser _createUser;
  final UpdateUser _updateUser;
  final DeleteUser _deleteUser;
  final DeleteAllUsers _deleteAllUsers;
  final SignIn _signIn;
  final SignOut _signOut;

  GeneralUserBloc({
    required GetAllUsers getAllUsers,
    required GetUserById getUserById,
    required CreateUser createUser,
    required UpdateUser updateUser,
    required DeleteUser deleteUser,
    required DeleteAllUsers deleteAllUsers,
    required SignIn signIn,
    required SignOut signOut,
  }) : _getAllUsers = getAllUsers,
   _getUserById = getUserById,
       _signIn = signIn,
       _signOut = signOut,
       _createUser = createUser,
       _updateUser = updateUser,
       _deleteUser = deleteUser,
       _deleteAllUsers = deleteAllUsers,
       super(GeneralUserInitial()) {
    on<UserSignInEvent>(_onSignIn);
    on<UserSignOutEvent>(_onSignOut);
    on<GetAllUsersEvent>(_onGetAllUsers);
    on<GetUserByIdEvent>(_onGetUserById);

    on<CreateUserEvent>(_onCreateUser);
    on<UpdateUserEvent>(_onUpdateUser);
    on<DeleteUserEvent>(_onDeleteUser);
    on<DeleteAllUsersEvent>(_onDeleteAllUsers);
  }

  Future<void> _onSignIn(
    UserSignInEvent event,
    Emitter<GeneralUserState> emit,
  ) async {
    emit(GeneralUserLoading());
    debugPrint('🔐 Processing sign in for: ${event.email}');

    final result = await _signIn(
      SignInParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) {
        debugPrint('❌ Sign in failed: ${failure.message}');
        emit(GeneralUserError(failure.message));
      },
      (user) {
        debugPrint('✅ Sign in successful for: ${user.email}');
        emit(UserAuthenticated(user));
      },
    );
  }

  Future<void> _onSignOut(
    UserSignOutEvent event,
    Emitter<GeneralUserState> emit,
  ) async {
    emit(GeneralUserLoading());
    debugPrint('🚪 Processing sign out');

    final result = await _signOut();

    result.fold(
      (failure) {
        debugPrint('❌ Sign out failed: ${failure.message}');
        emit(GeneralUserError(failure.message));
      },
      (_) {
        debugPrint('✅ Sign out successful');
        emit(const UserSignOutSuccess());
        emit(const UserUnauthenticated());
      },
    );
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

  Future<void> _onGetUserById(
  GetUserByIdEvent event,
  Emitter<GeneralUserState> emit,
) async {
  debugPrint('🔄 BLOC: Fetching user by ID: ${event.userId}');
  emit(GeneralUserLoading());

  final result = await _getUserById(event.userId);
  result.fold(
    (failure) {
      debugPrint('❌ BLOC: Failed to get user: ${failure.message}');
      emit(GeneralUserError(failure.message));
    },
    (user) {
      debugPrint('✅ BLOC: Successfully retrieved user: ${user.name}');
      emit(UserByIdLoaded(user));
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
