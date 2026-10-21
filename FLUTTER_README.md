# INTENT — Flutter + Express + SQL Server

The mobile app uses the existing JWT login and SQL Server configured in
`INTENT_Backend/.env`. Profiles and published requests are loaded from the API;
local secure storage holds only the login token. Chat and connection invitations
remain the existing demo features.

## Fixes and observed causes

- The supplied Flutter code had no HTTP, login or profile editing implementation:
  the profile edit option showed a placeholder. There was no failing Flutter API
  call in this snapshot to inspect. Unknown Express paths/methods returned the
  default HTML 404, explaining how a client could receive `<!DOCTYPE...` instead
  of JSON. All fallbacks and unhandled API errors now return JSON. The client
  checks HTTP status and content type and handles invalid JSON and network errors.
- The existing `PUT /api/auth/profile` updated SQL, then read `recordsets[1]`.
  An UPDATE without OUTPUT followed by one SELECT has only one recordset, so the
  route could report 404 even after a successful write. It now reads `recordset[0]`,
  preserves omitted optional fields, validates inputs, and uses only the JWT user.
  Flutter sends PUT, reloads with GET, and displays persisted profile fields.
- Requests were inserted only into an in-memory list initialized from demo data.
  There was no request API or database storage. New authenticated endpoints store
  requests in SQL, join the owner's current profile, and reload on login/startup,
  app resume, and opening Discover/Profile. Successful writes update the UI;
  failures retain the form with a retry action. A UUID retained by the form,
  a database primary key, and a transaction with key-range locks prevent duplicate
  writes on retries, including concurrent requests. An unresolved retry retains
  the original content; changing that content under the same ID returns 409.

## Backend setup and migration

The follow-up SSMS screenshot confirms `MSI\DB2K5` / `INTENT_DB` already has
`dbo.Intents`. Its columns are not visible in the supplied screenshot. Request
persistence is not yet mapped to that existing table: do not treat the new request
API as verified against this database. The migration now stops explicitly if
`dbo.Intents` exists and the proposed new table does not; it will not create a
parallel request store. Run the read-only `INTENT_Backend/scripts/inspect-schema.sql`
in SSMS and supply the metadata results so the API can reuse the existing schema.

The current backend configuration already uses `DB_SERVER=MSI\DB2K5`. The installed
mssql driver supports this named-instance syntax and parses the host/instance.
In the execution environment used here, the machine name is `ThanhDat`, hostname
`MSI` cannot be resolved, and no local DB2K5 SQL service is present. Connecting
requires the actual MSI machine to be reachable; pointing at a different local
SQL installation would not provide the database shown in the screenshot.
For named-instance discovery, SQL Server Browser/UDP 1434 must be reachable;
alternatively configure the real SQL host/IP and the instance's known TCP port.
See the [driver connection documentation](https://tediousjs.github.io/tedious/api-connection.html).
Do not assume a named instance uses TCP 1433. The inspection script's address/port
may be NULL if SSMS uses a local shared-memory connection.

Use Node.js 22 or newer with the existing SQL Server. Do not change database
engines. Keep the current `.env`; `.env.example` documents required variable names
without secrets. `DB_SERVER` must resolve from the machine running Node, and SQL
Server must accept TCP connections on `DB_PORT` (default 1433). Keep the existing
`DB_NAME`, credentials, JWT secret and optional mail configuration. No new backend
variables are required. Never commit `.env`.

From PowerShell:

```powershell
Set-Location D:\EXE101\INTENT_Backend
npm.cmd ci
npm.cmd run migrate
npm.cmd start
```

`migrations/001_profiles_requests.sql` runs against the configured database in a
transaction. It adds missing Major/Bio/Skills columns without overwriting existing
columns, and creates `dbo.IntentStudentRequests` only if absent. The table has a
UUID primary key, a foreign key using the actual `dbo.Users.UserId` type, request
fields, UTC creation time, a JSON tags constraint and an owner/time index. It
requires the existing `dbo.Users` table and SQL Server 2016+ for ISJSON. Supported
UserId types are int, bigint, uniqueidentifier, varchar and nvarchar. Unexpected
schemas fail explicitly; no new database or replacement tables are created.
The database user running migration needs ALTER/CREATE permissions. The migration
is repeatable and preserves existing rows. Run it before starting the updated app.

The backend reuses db.js for startup and fails startup when SQL/JWT configuration
is unavailable. It listens on all network interfaces for emulator/device access.

| Endpoint | Behavior |
| --- | --- |
| POST /api/auth/login | Existing email/password login, returns a 2-hour JWT |
| GET /api/auth/profile | Authenticated user's persisted profile |
| PUT /api/auth/profile | Update fullName and optional major/bio/skills |
| POST /api/requests | Publish id/title/description/tags/optional schedule |
| GET /api/requests | All published requests, visible to authenticated students |
| GET /api/requests/mine | Only the JWT user's requests; query userId is ignored |
| GET /api/health | Backend health |
| GET /api/db-test | Existing database diagnostic, now requires authentication |

Protected endpoints require `Authorization: Bearer <token>`. A POST returns 201
for a new UUID and 200 for the same owner's identical retry; conflicting content
or another owner's UUID returns 409. Client-supplied ownership/name fields are
ignored. Errors and unknown paths/methods return JSON. No profile endpoint exposes
password hashes or JWTs. Existing registration and password-reset routes remain.

## Flutter setup and runtime URL

Install Flutter with Dart >=3.3, then add Flutter to PATH. The supplied snapshot
contains lib/pubspec only, with no native/web runner folders. If those runners are
not restored from the full project, generate the missing runners from the root:

```powershell
flutter create --platforms=android,web --project-name=intent_mobile --empty .
```

Keep the existing lib, pubspec and application tests; do not use --overwrite.
See [Flutter CLI](https://docs.flutter.dev/reference/flutter-cli).

From the project root:

```powershell
Set-Location D:\EXE101
flutter pub get
flutter run -d chrome --web-port=8080 --dart-define=API_BASE_URL=http://localhost:3000/api
```

For an Android emulator:

```powershell
flutter run -d <emulator-id> --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

For a physical device, use the computer's reachable LAN IP or deployed HTTPS URL:

```powershell
flutter run -d <device-id> --dart-define=API_BASE_URL=http://<computer-lan-ip>:3000/api
```

API_BASE_URL includes `/api`, without an auth/profile/request suffix. If omitted,
Web uses the page's hostname and scheme on port 3000. Native apps require an
explicit value and show a configuration error if it is missing; the app does not
guess a loopback/emulator address for a physical phone. Set the value explicitly
for remote APIs, HTTPS hosting and nonstandard ports as well. Open the
backend port on the development network if needed. HTTPS pages need an HTTPS API.

For the requested Android APK and deployed Web build, use a reachable HTTPS API:

```powershell
flutter build apk --release --dart-define=API_BASE_URL=https://<backend-domain>/api
flutter build web --release --dart-define=API_BASE_URL=https://<backend-domain>/api
```

The APK is generated at `build/app/outputs/flutter-apk/app-release.apk`; host the
contents of `build/web` for Web. Replace the placeholder with the actual backend
domain. Changing this compile-time URL requires rebuilding the APK/Web bundle.
The database host in the backend .env is separate from the mobile API URL: the
phone connects to Express, and Express connects to SQL Server.

After native runner generation, ensure Android's main AndroidManifest.xml has
`<uses-permission android:name="android.permission.INTERNET" />`. For development
HTTP on Android, allow cleartext in a debug-only application manifest; use HTTPS
for release. Follow platform setup for
[flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage/versions/9.2.2),
including Keychain entitlements on Apple targets. Web token storage needs a secure
browser context (HTTPS or localhost); a fixed web port preserves the storage origin
between runs. Profiles and requests always come from SQL, not token storage.
Networking follows the [Flutter HTTP guidance](https://docs.flutter.dev/cookbook/networking/send-data).

Use an existing registered account. No client account-registration/password-reset
screen existed in the supplied Flutter snapshot; this fix adds the login needed
to use the existing backend authentication. Logout clears visible account state
and stored credentials; expired JWTs return to login. Restarting within a valid
session reloads the account's data from the API.

## Verification

```powershell
Set-Location D:\EXE101\INTENT_Backend
npm.cmd test
npm.cmd run test:db
Set-Location D:\EXE101
flutter analyze
flutter test
```

The default backend suite exercises real HTTP/Express/JWT with a SQL test double:
JSON 404/400/413/500, auth enforcement, first-recordset regression, optional-field
preservation/clearing, ownership, visibility, UUID conflict and retry behavior.
It does not prove SQL syntax or database persistence.

`test:db` explicitly uses the configured real SQL database after migration. It
creates two uniquely named fixture accounts, updates a profile, tests concurrent
POST retries, closes/reopens both Express and the SQL pool, logs in again, and
checks persisted rows, ownership and shared discovery. It removes only its own
new fixture rows afterwards. It must fail if the real database is unavailable.
Flutter tests cover missing APK configuration, HTML/invalid-JSON/server errors,
profile PUT/GET, expired auth, request model/ID round trips and the publishing
form's busy/error/retry behavior.

Manual checks on the target device/browser:

1. Sign in as A; edit all profile fields and save. Close/reopen the app and verify
   the values remain. Confirm the same values after logout/login.
2. Publish a request as A. Reopen Discover/Profile and restart the app. Confirm it
   remains once in Discover and A's own requests.
3. Sign in as B. B's profile and own list must contain only B's data. A's published
   request remains visible in shared Discover, matching the existing visibility.
4. Stop the backend and try saving/publishing. Confirm a visible error, retained
   form content and no success message. Restart it and retry; only one row should
   exist for that request ID.

Observed in this workspace during the fix: seven backend unit tests passed.
The real SQL connection failed with ENOTFOUND for the configured DB_SERVER;
schema inspection, migration, and the live database test could not complete.
No database rows were changed. `flutter analyze` and `flutter test` could not start
because Flutter/Dart were not found in PATH. Device/browser restart verification
has not been performed. These checks must be rerun once the environment is ready.

## Changed files

Modified:

- lib/main.dart
- lib/models/student_intent.dart
- lib/screens/app_shell.dart
- pubspec.yaml
- INTENT_Backend/db.js
- INTENT_Backend/server.js
- INTENT_Backend/routers.js
- INTENT_Backend/middleware/authMiddleware.js
- INTENT_Backend/package.json
- README.md

Added:

- lib/services/api_client.dart
- lib/screens/auth_screen.dart
- test/api_client_test.dart
- test/request_form_test.dart
- INTENT_Backend/app.js
- INTENT_Backend/routes/requests.js
- INTENT_Backend/migrations/001_profiles_requests.sql
- INTENT_Backend/scripts/migrate.js
- INTENT_Backend/scripts/inspect-schema.sql
- INTENT_Backend/test/api.test.js
- INTENT_Backend/test/db.integration.js
- INTENT_Backend/.env.example
- .gitignore
