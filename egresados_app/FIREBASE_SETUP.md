# Firebase Configuration for Flutter

## Setup Instructions

### 1. Android Setup
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Project Settings > General
4. Scroll down to "Your apps" section
5. Click on your Android app (or add one if you haven't)
6. Download `google-services.json`
7. Place it in: `egresados_app/android/app/google-services.json`

### 2. iOS Setup (if needed)
1. In Firebase Console, click on your iOS app
2. Download `GoogleService-Info.plist`
3. Place it in: `egresados_app/ios/Runner/GoogleService-Info.plist`

## Important Security Notes

⚠️ **NEVER commit these files to Git!**
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

These files are already added to `.gitignore` to prevent accidental commits.

## Team Setup

If you're working in a team:
1. Each developer must download their own copy of these files
2. Keep them in your local project directory only
3. Share the Firebase project access through Firebase Console instead
