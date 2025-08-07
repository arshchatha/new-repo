plugins {
    id("com.android.application")
    id("kotlin-android")
    id("kotlin-android-extensions")
    id("kotlin-kapt")
    id("kotlin-serialization")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    id("com.google.gms.oss-licenses-plugin")
    id("com.google.android.libraries.mapsplatform.secrets-gradle-plugin")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.lboard"
    minSdk = 21
    targetSdk = 36
    versionCode = 1
    versionName = "1.0"

    testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    compileSdk = 36
    buildToolsVersion = "36.0.0"
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.lboard"
        minSdk = 21
        targetSdk = 36
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        versionCode = 1
        versionName = "1.0"

        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            isShrinkResources = true
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            buildConfigField("String", "FLUTTER_BUILD_MODE", "\"release\"")
            buildConfigField("String", "FLUTTER_BUILD_SHA", "\"${System.getenv("FLUTTER_BUILD_SHA") ?: "unknown"}\"")
        }
    }
}

flutter {
    source = "src/main/flutter"
    versionCode = 1
    versionName = "1.0"
}
