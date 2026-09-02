import 'dart:js_interop';
import 'firebase_auth_service_stub.dart';

export 'firebase_auth_service_stub.dart' show FirebaseUserResult;

@JS('firebaseSignInWithGoogle')
external JSPromise<JSObject?> _jsSignInWithGoogle();

@JS('firebaseSignInWithEmail')
external JSPromise<JSObject?> _jsSignInWithEmail(JSString email, JSString password);

@JS('firebaseSignUpWithEmail')
external JSPromise<JSObject?> _jsSignUpWithEmail(JSString name, JSString email, JSString password);

@JS('firebaseSignOut')
external JSPromise<JSAny?> _jsSignOut();

extension type JSUser(JSObject _) implements JSObject {
  external JSString? get uid;
  external JSString? get displayName;
  external JSString? get email;
}

class FirebaseAuthPlatformService {
  static Future<FirebaseUserResult?> signInWithGoogle() async {
    try {
      final jsResult = await _jsSignInWithGoogle().toDart;
      if (jsResult == null) return null;

      final user = JSUser(jsResult);
      return FirebaseUserResult(
        uid: user.uid?.toDart ?? '',
        displayName: user.displayName?.toDart ?? 'Google User',
        email: user.email?.toDart ?? '',
      );
    } catch (e) {
      throw 'Google Sign-In error: $e';
    }
  }

  static Future<FirebaseUserResult?> signInWithEmail(
      String email, String password) async {
    try {
      final jsResult = await _jsSignInWithEmail(email.toJS, password.toJS).toDart;
      if (jsResult == null) return null;

      final user = JSUser(jsResult);
      return FirebaseUserResult(
        uid: user.uid?.toDart ?? '',
        displayName: user.displayName?.toDart ?? email.split('@').first,
        email: user.email?.toDart ?? email,
      );
    } catch (e) {
      throw 'Sign in error: $e';
    }
  }

  static Future<FirebaseUserResult?> signUpWithEmail(
      String name, String email, String password) async {
    try {
      final jsResult = await _jsSignUpWithEmail(name.toJS, email.toJS, password.toJS).toDart;
      if (jsResult == null) return null;

      final user = JSUser(jsResult);
      return FirebaseUserResult(
        uid: user.uid?.toDart ?? '',
        displayName: user.displayName?.toDart ?? name,
        email: user.email?.toDart ?? email,
      );
    } catch (e) {
      throw 'Sign up error: $e';
    }
  }

  static Future<void> signOut() async {
    try {
      await _jsSignOut().toDart;
    } catch (_) {}
  }

  static FirebaseUserResult? getCurrentUser() => null;
}
