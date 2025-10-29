import 'dart:async';
import 'auth_remote_ds.dart';

class MockAuthRemoteDs implements AuthRemoteDs {
  final _ctrl = StreamController<RemoteUser?>.broadcast();
  RemoteUser? _current;

  MockAuthRemoteDs() {
    _ctrl.add(null); // ban đầu chưa đăng nhập
  }

  // === LƯU Ý: getter, không phải method ===
  @override
  Stream<RemoteUser?> get authState$ => _ctrl.stream;

  @override
  Future<RemoteUser> register({
    required String email,
    required String password,
  }) async {
    _current = RemoteUser(
      uid: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      displayName: email.split('@').first,
    );
    _ctrl.add(_current);
    return _current!;
  }

  @override
  Future<RemoteUser> signInEmail({
    required String email,
    required String password,
  }) async {
    _current = RemoteUser(
      uid: 'mock-${email.hashCode}',
      email: email,
      displayName: email.split('@').first,
    );
    _ctrl.add(_current);
    return _current!;
  }

  @override
  Future<RemoteUser> signInGoogle() async {
    _current = const RemoteUser(
      uid: 'mock-google',
      email: 'mock@gmail.com',
      displayName: 'Mock Google',
    );
    _ctrl.add(_current);
    return _current!;
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _ctrl.add(null);
  }
}
