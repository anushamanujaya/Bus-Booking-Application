1) Install Firebase CLI and FlutterFire CLI
   - npm i -g firebase-tools
   - dart pub global activate flutterfire_cli

2) Create a Firebase project in the console and enable:
   - Firestore (in test mode for now)
   - Cloud Functions (if you plan server-side Stripe integration)

3) Configure your Flutter app:
   - Run `flutterfire configure` in the project root and follow prompts. This will create `firebase_options.dart`.
   - Add platform-specific Firebase config (Android: google-services.json, iOS: GoogleService-Info.plist) if requested.

4) Firestore rules (basic for dev):
   - Start with test rules; lock down rules later as needed for production data paths like bookings/trips.

5) Stripe integration notes:
   - For secure payments, create a Cloud Function (or small backend) to create PaymentIntents using your Stripe secret key.
   - Call that function from the app and confirm payment using `flutter_stripe` on the client.

6) Quick commands:
   - `flutter pub get`
   - `flutter run` (after firebase configure / platform setup)

If you want, I can scaffold a Cloud Function (Node) for creating a Stripe PaymentIntent next.