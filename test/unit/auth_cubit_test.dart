import 'package:finflow/core/error/failure.dart';
import 'package:finflow/core/error/result.dart';
import 'package:finflow/features/auth/domain/entities/app_user.dart';
import 'package:finflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:finflow/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
    when(() => repository.currentUser).thenReturn(null);
    when(
      () => repository.onAuthStateChanged,
    ).thenAnswer((_) => const Stream<AppUser?>.empty());
  });

  group('AuthCubit', () {
    test('initial state is unauthenticated when currentUser is null', () {
      final cubit = AuthCubit(repository);
      expect(cubit.state.status, AuthStatus.unauthenticated);
      expect(cubit.state.user, null);
    });

    test('sign in with email succeeds', () async {
      const user = AppUser(uid: 'u1', email: 'test@example.com');
      when(
        () => repository.signInWithEmail('test@example.com', '123456'),
      ).thenAnswer((_) async => const Success(user));

      final cubit = AuthCubit(repository);
      await cubit.signInWithEmail('test@example.com', '123456');

      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.user, user);
    });

    test('sign up with email succeeds', () async {
      const user = AppUser(uid: 'u2', email: 'new@example.com');
      when(
        () => repository.signUpWithEmail('new@example.com', '123456'),
      ).thenAnswer((_) async => const Success(user));

      final cubit = AuthCubit(repository);
      await cubit.signUpWithEmail('new@example.com', '123456');

      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.user, user);
    });

    test('sign in anonymously succeeds', () async {
      const user = AppUser(uid: 'guest_1', isAnonymous: true);
      when(
        () => repository.signInAnonymously(),
      ).thenAnswer((_) async => const Success(user));

      final cubit = AuthCubit(repository);
      await cubit.signInAnonymously();

      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.user, user);
    });

    test('successful sign out clears the authenticated user', () async {
      const user = AppUser(uid: 'u1', email: 'test@example.com');
      when(() => repository.currentUser).thenReturn(user);
      when(
        () => repository.signOut(),
      ).thenAnswer((_) async => const Success(null));

      final cubit = AuthCubit(repository);
      addTearDown(cubit.close);
      await cubit.signOut();

      expect(cubit.state.status, AuthStatus.unauthenticated);
      expect(cubit.state.user, isNull);
    });

    test('failed sign out keeps the authenticated user', () async {
      const user = AppUser(uid: 'u1', email: 'test@example.com');
      const failure = NetworkFailure('offline');
      when(() => repository.currentUser).thenReturn(user);
      when(
        () => repository.signOut(),
      ).thenAnswer((_) async => const Error(failure));

      final cubit = AuthCubit(repository);
      addTearDown(cubit.close);
      await cubit.signOut();

      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.user, user);
      expect(cubit.state.failure, failure);
    });
  });
}
