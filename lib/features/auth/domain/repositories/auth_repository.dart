import '../../../../core/error/result.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get onAuthStateChanged;
  AppUser? get currentUser;

  Future<Result<AppUser>> signInWithEmail(String email, String password);
  Future<Result<AppUser>> signUpWithEmail(String email, String password);
  Future<Result<AppUser>> signInAnonymously();
  Future<Result<void>> signOut();
}
