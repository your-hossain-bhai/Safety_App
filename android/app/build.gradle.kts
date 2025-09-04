plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.login_signup"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.example.login_signup"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Use Java 17 for AGP/Gradle 8.x
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            // For demo/dev builds keep shrinking OFF
            isMinifyEnabled = false
            isShrinkResources = false   // <- Kotlin DSL uses isShrinkResources

            signingConfig = signingConfigs.getByName("debug")
        }
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    // If you previously added NDK, remove it unless you really need it:
    // ndkVersion = "27.0.12077973"
}

flutter {
    source = "../.."
}

dependencies {
    // Flutter plugins from pubspec.yaml are enough
}
