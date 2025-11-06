import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // Regular auth state stream
  Stream<User?> get authStateChanges => _authService.authStateChanges();

  // Verified user stream: only emits if user is logged in and email verified
  Stream<User?> get verifiedUserStream async* {
    await for (final user in _authService.authStateChanges()) {
      if (user != null) {
        await user.reload(); // make sure emailVerified is up-to-date
        if (user.emailVerified || user.providerData.any((p) => p.providerId != 'password')) {
          // Allow Google or other provider logins even without email verification
          yield user;
        } else {
          yield null; // treat unverified email as logged out
        }
      } else {
        yield null;
      }
    }
  }

  User? get user => _authService.currentUser;

  Future<void> signUp(String email, String password) async {
    await _authService.signUp(email, password);
    await _authService.sendEmailVerification();
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    await _authService.signIn(email, password);
    await _authService.reloadUser();
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    await _authService.signInWithGoogle();
    await _authService.reloadUser();
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    notifyListeners();
  }

  Future<void> reloadUser() async {
    await _authService.reloadUser();
    notifyListeners();
  }
}
