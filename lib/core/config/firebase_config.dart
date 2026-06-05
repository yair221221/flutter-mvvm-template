/// Set to [true] after you have:
///   1. Created a Firebase project at console.firebase.google.com
///   2. Replaced android/app/google-services.json with your real config
///   3. Enabled Anonymous Authentication in the Firebase console
///   4. Created a Firestore database (start in test mode for development)
///
/// When [false] (default), the app uses local mock data for friends and
/// does not write wellness scores to the cloud.
const bool kFirebaseEnabled = false;
