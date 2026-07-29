import 'package:firebase_auth/firebase_auth.dart';
import 'package:finflow/core/error/result.dart';
import 'package:finflow/features/auth/data/repositories/firebase_auth_repository_impl.dart';
import 'package:finflow/features/auth/domain/entities/app_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  late MockFirebaseAuth auth;

  setUp(() {
    auth = MockFirebaseAuth();
    when(() => auth.currentUser).thenReturn(null);
    when(
      () => auth.authStateChanges(),
    ).thenAnswer((_) => const Stream<User?>.empty());
  });

  test('falls back to a persisted local guest when offline', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = FirebaseAuthRepositoryImpl(preferences, auth: auth);
    when(() => auth.signInAnonymously()).thenThrow(
      FirebaseAuthException(code: 'network-request-failed', message: 'offline'),
    );

    final result = await repository.signInAnonymously();

    expect(result, isA<Success<AppUser>>());
    expect(
      repository.currentUser,
      const AppUser(uid: 'guest', isAnonymous: true),
    );
    expect(preferences.getBool('finflow_local_guest'), isTrue);
  });

  test('restores the local guest on the next launch', () async {
    SharedPreferences.setMockInitialValues({'finflow_local_guest': true});
    final preferences = await SharedPreferences.getInstance();
    final repository = FirebaseAuthRepositoryImpl(preferences, auth: auth);

    expect(
      repository.currentUser,
      const AppUser(uid: 'guest', isAnonymous: true),
    );
  });
}
