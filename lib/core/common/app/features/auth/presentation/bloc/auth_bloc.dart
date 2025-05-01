import 'package:xpro_delivery_admin_app/core/common/app/features/auth/domain/usecases/get_all_user.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/auth/domain/usecases/get_token.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/auth/domain/usecases/get_user_by_id.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/auth/domain/usecases/sign_in.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/auth/domain/usecases/sign_out.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:xpro_delivery_admin_app/core/common/app/features/auth/presentation/bloc/auth_event.dart';
import 'package:xpro_delivery_admin_app/core/common/app/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUsecase _signInUsecase;
  final SignOutUsecase _signOutUsecase;
  final GetTokenUsecase _getTokenUsecase;
  final GetAllUsersUsecase _getAllUsersUsecase;
  final GetUserByIdUsecase _getUserByIdUsecase;

  AuthBloc({
    required SignInUsecase signInUsecase,
    required SignOutUsecase signOutUsecase,
    required GetTokenUsecase getTokenUsecase,
    required GetAllUsersUsecase getAllUsersUsecase,
    required GetUserByIdUsecase getUserByIdUsecase,
  })  : _signInUsecase = signInUsecase,
        _signOutUsecase = signOutUsecase,
        _getTokenUsecase = getTokenUsecase,
        _getAllUsersUsecase = getAllUsersUsecase,
        _getUserByIdUsecase = getUserByIdUsecase,
        super(const AuthInitial()) {
    on<SignInEvent>(_onSignIn);
    on<SignOutEvent>(_onSignOut);
    on<GetAuthTokenEvent>(_onGetAuthToken);
    on<GetAllUsersEvent>(_onGetAllUsers);
    on<GetUserByIdEvent>(_onGetUserById);
    on<AuthInitialEvent>(_onAuthInitial);
  }

  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    debugPrint('🔐 Processing sign in for: ${event.email}');

    final result = await _signInUsecase(
      SignInParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) {
        debugPrint('❌ Sign in failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) {
        debugPrint('✅ Sign in successful for: ${user.email}');
        emit(Authenticated(user));
      },
    );
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    debugPrint('🚪 Processing sign out');

    final result = await _signOutUsecase();

    result.fold(
      (failure) {
        debugPrint('❌ Sign out failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (_) {
        debugPrint('✅ Sign out successful');
        emit(const SignOutSuccess());
        emit(const Unauthenticated());
      },
    );
  }

  Future<void> _onGetAuthToken(
      GetAuthTokenEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    debugPrint('🔑 Retrieving auth token');

    final result = await _getTokenUsecase();

    result.fold(
      (failure) {
        debugPrint('❌ Token retrieval failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (token) {
        debugPrint('🔑 Token retrieved: ${token != null ? 'Valid token' : 'No token'}');
        emit(TokenLoaded(token));
      },
    );
  }

  Future<void> _onGetAllUsers(
      GetAllUsersEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    debugPrint('👥 Fetching all users');

    final result = await _getAllUsersUsecase();

    result.fold(
      (failure) {
        debugPrint('❌ User fetch failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (users) {
        debugPrint('✅ Retrieved ${users.length} users');
        emit(UsersLoaded(users));
      },
    );
  }

  Future<void> _onGetUserById(
      GetUserByIdEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    debugPrint('🔍 Fetching user with ID: ${event.userId}');

    final result = await _getUserByIdUsecase(
      GetUserByIdParams(userId: event.userId),
    );

    result.fold(
      (failure) {
        debugPrint('❌ User fetch failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) {
        debugPrint('✅ Retrieved user: ${user.name}');
        emit(UserLoaded(user));
      },
    );
  }

  Future<void> _onAuthInitial(
      AuthInitialEvent event, Emitter<AuthState> emit) async {
    emit(const AuthInitial());
  }
}
