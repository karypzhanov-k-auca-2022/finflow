import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepositoryImpl implements AuthRepository {
  FirebaseAuthRepositoryImpl({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

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
      _auth.authStateChanges().map(_mapUser);

  @override
  AppUser? get currentUser => _mapUser(_auth.currentUser);

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
      return Success(user);
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return const Success(null);
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }
}
