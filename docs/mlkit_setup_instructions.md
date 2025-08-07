# Google ML Kit Text Recognizer Setup Instructions

To resolve the "MissingPluginException" error and properly integrate Google ML Kit Text Recognizer in your Flutter project, follow these steps:

## 1. Add Dependencies

In your `pubspec.yaml`, add the following dependencies:

```yaml
dependencies:
  google_mlkit_text_recognition: ^0.3.0
  # Add other dependencies as needed
```

Run:

```bash
flutter pub get
```

## 2. Android Setup

- In `android/build.gradle`, ensure the `minSdkVersion` is at least 21:

```gradle
buildscript {
    ext {
        minSdkVersion = 21
        // other configs
    }
}
```

- In `android/app/build.gradle`, ensure the `minSdkVersion` is at least 21:

```gradle
android {
    defaultConfig {
        minSdkVersion 21
        // other configs
    }
}
```

- Add Google services plugin if not already added:

In `android/build.gradle`:

```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.10'
}
```

In `android/app/build.gradle`:

```gradle
apply plugin: 'com.google.gms.google-services'
```

- Ensure your `android/app/src/main/AndroidManifest.xml` has internet permission:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## 3. iOS Setup

- In `ios/Podfile`, uncomment or add platform version:

```ruby
platform :ios, '11.0'
```

- Run:

```bash
cd ios
pod install
cd ..
```

- Add the following keys to `ios/Runner/Info.plist` for camera and photo library usage if needed:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for text recognition</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Photo library access is required for text recognition</string>
```

## 4. Rebuild the App

After completing the above steps, stop any running instances and run:

```bash
flutter clean
flutter pub get
flutter run
```

## 5. Verify Platform Support

- Ensure you are running on a physical device or emulator that supports Google Play services (Android) or the required iOS capabilities.

## 6. Additional Notes

- If you are using Flutter web or desktop, Google ML Kit Text Recognizer may not be supported.
- Check the official plugin documentation for the latest setup instructions: https://pub.dev/packages/google_mlkit_text_recognition

---

If you want, I can help you apply these setup steps or troubleshoot further.
