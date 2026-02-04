Day-1 MVP sprint (target: complete core flow locally)

Priority tasks (today):
1. Configure Firebase for the app (`flutterfire configure`). 
2. (Removed) Auth UI / Firebase Auth is not part of this sprint.
3. Implement Search → Trips list → Seat selection flow (UI skeleton in place).
4. Add Stripe integration backend (Cloud Function) to create PaymentIntents (I can scaffold this next).
5. Wire up seat-locking using Firestore transactions (next step after basic CRUD).
6. Testing: run app on emulator and verify sign-up / sign-in + navigation.

If you confirm, I can scaffold a Cloud Function to create Stripe PaymentIntents and a minimal Firestore seat-lock transaction example next.