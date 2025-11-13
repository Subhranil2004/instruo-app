### Cross-platform Flutter + Firebase mobile application

> Copied from a group project hosted in [this](https://github.com/Harshit-Kr01/InstruoApplication) GitHub repo 

<details>
<summary><h3>In-app updates workflow</h3> (click to expand)</summary>
  
- Add permission to `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <uses-permission android:name="android.permission.INTERNET"/>
  <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
  ```

- Make sure you have a release keystore (key.jks or .keystore). If you do not have one, create it:
  If you want the keystore to live in the project (convenient for local builds), create it in the android folder of your repo:
  Run this command from the root of your project
  ```bash
  # from project root (PowerShell) creates for 10000 days validity
  keytool -genkey -v -keystore ".\android\release-key.jks" -alias release_key -keyalg RSA -keysize 2048 -validity 10000
  ```
- Add key.properties in `android/` with your keystore details:
  ```ini
  storePassword=<your-store-password>
  keyPassword=<your-key-password>
  keyAlias=release_key
  storeFile=android/release-key.jks
  ```

- Add to `.gitignore`
  ```gitignore
  /key.properties
  /android/release-key.jks
  ```

- Configure build.gradle (not done currently)

- Build the signed APK
  ```
  flutter clean
  flutter pub get
  flutter build apk --release
  # output: build/app/outputs/flutter-apk/app-release.apk
  ```

  Or build an AAB if you plan to upload to Play Store: `flutter build appbundle --release`

- Compute SHA-256 of APK (for manifest)
  ```
  Get-FileHash .\build\app\outputs\flutter-apk\app-release.apk -Algorithm SHA256
  ```

- manifest.json
  ```json
  {
    "versionName": "1.0.0",
    "versionCode": 1,
    "notes": "Initial public release",
    "apk_url": "https://github.com/Subhranil2004/instruo-app/releases/download/v1.0.0/app-release.apk",
    "sha256": "PASTE_SHA256_HEX_HERE"
  
  }
  ```
</details>
