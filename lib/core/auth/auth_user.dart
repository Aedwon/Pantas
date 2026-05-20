import 'package:meta/meta.dart';

@immutable
class AuthUser {
  const AuthUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.isPro = false,
  });

  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final bool isPro;

  @override
  bool operator ==(Object other) {
    return other is AuthUser &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoUrl == photoUrl &&
        other.isPro == isPro;
  }

  @override
  int get hashCode {
    return Object.hash(uid, email, displayName, photoUrl, isPro);
  }
}
