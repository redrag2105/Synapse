import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      return _auth.signInWithPopup(provider);
    }

    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;

      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'missing-id-token',
          message:
              'Google Sign-In did not return an ID token. '
              'Register this machine’s debug SHA-1 in Firebase and '
              're-download google-services.json.',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      return _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      throw FirebaseAuthException(
        code: _mapGoogleSignInCode(e),
        message: _mapGoogleSignInMessage(e),
      );
    }
  }

  String _mapGoogleSignInCode(GoogleSignInException e) {
    final detail = (e.description ?? '').toLowerCase();
    // Google reports SHA/OAuth misconfig as "canceled" + "[16] Account reauth failed".
    if (detail.contains('reauth failed') || detail.contains('[16]')) {
      return 'sha-mismatch';
    }
    if (e.code == GoogleSignInExceptionCode.canceled) {
      return 'aborted-by-user';
    }
    return 'google-sign-in-failed';
  }

  String _mapGoogleSignInMessage(GoogleSignInException e) {
    final detail = (e.description ?? '').toLowerCase();
    if (detail.contains('reauth failed') || detail.contains('[16]')) {
      return 'Google Sign-In rejected this app build (SHA-1 mismatch). '
          'Add your debug SHA-1 to Firebase → Project settings → Android app, '
          'then re-download google-services.json and rebuild.';
    }
    if (e.code == GoogleSignInExceptionCode.canceled) {
      return 'Google sign-in was cancelled.';
    }
    return e.description ?? e.toString();
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      await GoogleSignIn.instance.signOut();
    }
    await _auth.signOut();
  }
}
