import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepositoryImpl implements AuthRepository {
  FirebaseAuthRepositoryImpl(this.preferences, {FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  static const _localGuestKey = 'finflow_local_guest';
  final SharedPreferences preferences;
  final FirebaseAuth _auth;

  AppUser? get _localGuest => preferences.getBool(_localGuestKey) ?? false
      ? const AppUser(uid: 'guest', isAnonymous: true)
      : null;

  AppUser? _mapUser(User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email,
      isAnonymous: user.isAnonymous,
    );
  }

  @override
  Stream<AppUser?> get onAuthStateChanged =>
      _auth.authStateChanges().map((user) => _mapUser(user) ?? _localGuest);

  @override
  AppUser? get currentUser => _mapUser(_auth.currentUser) ?? _localGuest;

  @override
  Future<Result<AppUser>> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = _mapUser(credential.user);
      if (user == null) {
        return const Error(UnknownFailure('Failed to sign in'));
      }
      await preferences.setBool(_localGuestKey, false);
      return Success(user);
    } on FirebaseAuthException catch (e) {
      return Error(NetworkFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<AppUser>> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = _mapUser(credential.user);
      if (user == null) {
        return const Error(UnknownFailure('Failed to create user'));
      }
      await preferences.setBool(_localGuestKey, false);
      return Success(user);
    } on FirebaseAuthException catch (e) {
      return Error(NetworkFailure(e.message ?? 'Registration failed'));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<AppUser>> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      final user = _mapUser(credential.user);
      if (user == null) {
        return const Error(UnknownFailure('Failed to sign in as guest'));
      }
      await preferences.setBool(_localGuestKey, false);
      return Success(user);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'network-request-failed') {
        const guest = AppUser(uid: 'guest', isAnonymous: true);
        await preferences.setBool(_localGuestKey, true);
        return const Success(guest);
      }
      return Error(
        UnknownFailure(error.message ?? 'Failed to sign in as guest'),
      );
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await preferences.setBool(_localGuestKey, false);
      await _auth.signOut();
      return const Success(null);
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }
}
