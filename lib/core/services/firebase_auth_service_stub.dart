class FirebaseUserResult {
  final String uid;
  final String displayName;
  final String email;

  const FirebaseUserResult({
    required this.uid,
    required this.displayName,
    required this.email,
  });
}

class FirebaseAuthPlatformService {
  static Future<FirebaseUserResult?> signInWithGoogle() async {
    return const FirebaseUserResult(
      uid: 'fb-google-test',
      displayName: 'Dhyanesh',
      email: 'dhyanesh@example.com',
    );
  }

  static Future<FirebaseUserResult?> signInWithEmail(
      String email, String password) async {
    return FirebaseUserResult(
      uid: 'fb-email-${email.hashCode}',
      displayName: email.split('@').first,
      email: email,
    );
  }

  static Future<FirebaseUserResult?> signUpWithEmail(
      String name, String email, String password) async {
    return FirebaseUserResult(
      uid: 'fb-email-${email.hashCode}',
      displayName: name.isNotEmpty ? name : email.split('@').first,
      email: email,
    );
  }

  static Future<void> signOut() async {}

  static FirebaseUserResult? getCurrentUser() => null;
}
