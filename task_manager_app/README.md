# Task Manager App (Flutter + Firebase)

Production-level Flutter task manager app created for internship submission.

## Features

- Firebase Authentication (signup, login, logout, persistent session)
- Cloud Firestore CRUD (add, edit, delete, complete task)
- Task filtering (All / Completed / Pending)
- Real-time Firestore updates
- Pull-to-refresh task list and quote
- Motivational quote API integration from `https://api.quotable.io/random`
- Material 3 responsive UI with reusable widgets
- Form validation, loading indicators, snackbar-based feedback

## Folder Structure

```text
lib/
├── constants/
├── models/
├── screens/
├── services/
├── utils/
├── widgets/
└── main.dart
```

## Dependencies

- `provider`
- `firebase_core`
- `firebase_auth`
- `cloud_firestore`
- `http`
- `intl`

## Setup Instructions

### 1) Prerequisites

- Flutter stable (3.41+)
- Android Studio + SDK
- Firebase project

### 2) Install dependencies

```bash
flutter pub get
```

### 3) Firebase setup (outside Cursor, you should do this)

1. Go to [Firebase Console](https://console.firebase.google.com/) and create a project.
2. Enable **Authentication** -> **Sign-in method** -> **Email/Password**.
3. Enable **Cloud Firestore** in production mode.
4. Add Android app:
   - package name from `android/app/build.gradle.kts` (`applicationId`)
   - download `google-services.json` into `android/app/`
5. Add iOS app:
   - bundle id from Xcode
   - download `GoogleService-Info.plist` into `ios/Runner/`
6. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
7. Configure firebase:
   ```bash
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart`.
8. In `lib/main.dart`, switch initialization to:
   ```dart
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

### 4) Firestore security rules

Use rules similar to:

```text
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/tasks/{taskId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 5) Run the app

```bash
flutter run
```

## Build APK

```bash
flutter build apk --release
```

## Notes

- If Windows shows symlink errors, enable Developer Mode:
  - Run `start ms-settings:developers`
  - Toggle **Developer Mode** ON.
- For Windows desktop builds, install Visual Studio with the Desktop C++ workload.
