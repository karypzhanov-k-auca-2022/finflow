import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    this.email,
    this.isAnonymous = false,
  });

  final String uid;
  final String? email;
  final bool isAnonymous;

  String get displayName => email ?? (isAnonymous ? 'Guest User' : 'User');

  @override
  List<Object?> get props => [uid, email, isAnonymous];
}
