// lib/presentation/auth/auth_state.dart
import 'dart:async';
import 'package:flutter/foundation.dart' show ChangeNotifier, kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';

enum AuthStatus { idle, loading, error }

class AuthState extends ChangeNotifier {
  final FirebaseAuth _auth;

  AuthStatus _status = AuthStatus.idle;
  String? _error;
  User? _user;
  StreamSubscription<User?>? _sub;

  AuthState({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  // getters
  AuthStatus get status => _status;
  String? get error => _error;
  User? get user => _user;
  bool get isSignedIn => _user != null;

  void _setLoading() {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
  }

  void _setIdle() {
    _status = AuthStatus.idle;
    notifyListeners();
  }

  void _setError(Object e) {
    _status = AuthStatus.error;
    _error = e.toString();
    notifyListeners();
  }

  /// Lắng nghe đăng nhập/đăng xuất
  void bindAuthStream() {
    _sub?.cancel();
    _sub = _auth.authStateChanges().listen((u) {
      _user = u;
      if (_status != AuthStatus.loading) _status = AuthStatus.idle;
      notifyListeners();
    });
  }

  /// Đăng ký email/password
  Future<void> registerWithEmail(String email, String password) async {
    _setLoading();
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _setIdle();
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? e.code);
    } catch (e) {
      _setError(e);
    }
  }

  /// Đăng nhập email/password
  Future<void> signInWithEmail(String email, String password) async {
    _setLoading();
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _setIdle();
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? e.code);
    } catch (e) {
      _setError(e);
    }
  }

  /// Đăng nhập Google (không cần plugin google_sign_in)
  Future<void> signInWithGoogle() async {
    _setLoading();
    try {
      final provider = GoogleAuthProvider()
        ..setCustomParameters({'prompt': 'select_account'});

      if (kIsWeb) {
        await _auth.signInWithPopup(provider);
      } else {
        await _auth.signInWithProvider(provider);
      }
      _setIdle();
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? e.code);
    } catch (e) {
      _setError(e);
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    _setLoading();
    try {
      await _auth.signOut();
      _setIdle();
    } catch (e) {
      _setError(e);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
