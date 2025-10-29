import 'package:flutter/foundation.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/sign_in_email_uc.dart';

class AuthVm extends ChangeNotifier {
  final SignInEmailUc _signInEmail;
  AuthVm(this._signInEmail);

  UserEntity? current;
  String? error;
  bool isLoading = false;

  Future<void> onSignIn(String email, String pwd) async {
    error = null;
    isLoading = true;
    notifyListeners();

    final r = await _signInEmail(SignInEmailParams(email, pwd));

    r.match(
      ok: (user) {
        current = user;
        error = null;
      },
      err: (f) {
        error = f.message;
      },
    );

    isLoading = false;
    notifyListeners();
  }
}

