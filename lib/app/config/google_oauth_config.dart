/// OAuth client IDs used by Google Sign-In / Firebase Auth.
///
/// [webClientId] must be the **Web** client (type 3) from Firebase /
/// Google Cloud Console — required as `serverClientId` on Android so
/// `authenticate()` returns an ID token for Firebase.
abstract final class GoogleOAuthConfig {
  static const String webClientId =
      '759130064327-r0nh3sc1413tmgl0vdsuu4bv2nqk4o21.apps.googleusercontent.com';
}
