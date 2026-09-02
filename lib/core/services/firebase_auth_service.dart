import 'firebase_auth_service_stub.dart'
    if (dart.library.html) 'firebase_auth_service_web.dart';

export 'firebase_auth_service_stub.dart' show FirebaseUserResult;

class FirebaseAuthService {
  static Future<FirebaseUserResult?> signInWithGoogle() =>
      FirebaseAuthPlatformService.signInWithGoogle();

  static Future<FirebaseUserResult?> signInWithEmail(
          String email, String password) =>
      FirebaseAuthPlatformService.signInWithEmail(email, password);

  static Future<FirebaseUserResult?> signUpWithEmail(
          String name, String email, String password) =>
      FirebaseAuthPlatformService.signUpWithEmail(name, email, password);

  static Future<void> signOut() => FirebaseAuthPlatformService.signOut();

  static FirebaseUserResult? getCurrentUser() =>
      FirebaseAuthPlatformService.getCurrentUser();
}
