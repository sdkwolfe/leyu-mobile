# Fix login to use email

This is a placeholder commit for: "Fix login to use email".

What to change (next steps):

1. Locate the login/authentication UI and logic
   - Likely files: `lib/screens/login.dart`, `lib/pages/auth/login_page.dart`, or `lib/auth/*`
   - Replace any "username" or "handle" fields with an `email` field
   - Update validators to check email format (e.g., RegExp)

2. Update request payloads and backend integration
   - Ensure the HTTP/auth request uses `email` as the identifier instead of `username`
   - Update DTOs / request models in `lib/services` or `lib/api`

3. Update local state and storage
   - If app stores a username in secure storage/shared preferences for login, migrate to `email`

4. Update tests
   - Modify existing login tests to use `email` and add tests for invalid email formats

5. Manual QA
   - Test authentication flow on Android and iOS devices or emulators

If you want I can make a best-effort code change now (search for the login code, update the field names and request payloads) and push it to `main`. Otherwise this file documents the work to be done.
