import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.initial, this.user, this.failure});

  final AuthStatus status;
  final AppUser? user;
  final Failure? failure;

  @override
  List<Object?> get props => [status, user, failure];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this.repository)
    : super(
        AuthState(
          status: repository.currentUser != null
              ? AuthStatus.authenticated
              : AuthStatus.unauthenticated,
          user: repository.currentUser,
        ),
      ) {
    _subscription = repository.onAuthStateChanged.listen((user) {
      if (user != null) {
        emit(AuthState(status: AuthStatus.authenticated, user: user));
      } else {
        emit(const AuthState(status: AuthStatus.unauthenticated));
      }
    });
  }

  final AuthRepository repository;
  late final StreamSubscription<AppUser?> _subscription;

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }

  Future<void> signInWithEmail(String email, String password) async {
    emit(AuthState(status: AuthStatus.loading, user: state.user));
    final res = await repository.signInWithEmail(email, password);
    res.fold(
      (failure) =>
          emit(AuthState(status: AuthStatus.unauthenticated, failure: failure)),
      (user) => emit(AuthState(status: AuthStatus.authenticated, user: user)),
    );
  }

  Future<void> signUpWithEmail(String email, String password) async {
    emit(AuthState(status: AuthStatus.loading, user: state.user));
    final res = await repository.signUpWithEmail(email, password);
    res.fold(
      (failure) =>
          emit(AuthState(status: AuthStatus.unauthenticated, failure: failure)),
      (user) => emit(AuthState(status: AuthStatus.authenticated, user: user)),
    );
  }

  Future<void> signInAnonymously() async {
    emit(AuthState(status: AuthStatus.loading, user: state.user));
    final res = await repository.signInAnonymously();
    res.fold(
      (failure) =>
          emit(AuthState(status: AuthStatus.unauthenticated, failure: failure)),
      (user) => emit(AuthState(status: AuthStatus.authenticated, user: user)),
    );
  }

  Future<void> signOut() async {
    emit(const AuthState(status: AuthStatus.loading));
    await repository.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
