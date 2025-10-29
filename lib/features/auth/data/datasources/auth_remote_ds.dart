import 'dart:async';

class RemoteUser {
  final String uid;
  final String email;
  final String displayName;
  const RemoteUser({
    required this.uid,
    required this.email,
    required this.displayName,
  });
}

abstract class AuthRemoteDs {
  /// Stream trạng thái đăng nhập (null = chưa đăng nhập)
  Stream<RemoteUser?> get authState$;

  Future<RemoteUser> register({
    required String email,
    required String password,
  });

  Future<RemoteUser> signInEmail({
    required String email,
    required String password,
  });

  Future<RemoteUser> signInGoogle();

  Future<void> signOut();
}
