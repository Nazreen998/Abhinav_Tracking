plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.location_tracking"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.location_tracking"

        minSdk = flutter.minSdkVersion               // ✅ CORRECT SYNTAX
        targetSdk = 36           // ✅ CORRECT
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Use debug signing for now
            signingConfig = signingConfigs.getByName("debug")  // ✅ CORRECT
            isMinifyEnabled = false                            // ✅ CORRECT
            isShrinkResources = false                          // ✅ CORRECT
        }
    }
}

flutter {
    source = "../.."
}
