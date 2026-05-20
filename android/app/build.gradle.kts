plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.aedwon.cse_cet_reviewer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.aerol.csecet"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "default"
    productFlavors {
        create("dev") {
            dimension = "default"
            applicationId = "com.aerol.csecet.dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "CSE/CET Reviewer Dev")
        }
        create("staging") {
            dimension = "default"
            applicationId = "com.aerol.csecet.dev.staging"
            versionNameSuffix = "-staging"
            resValue("string", "app_name", "CSE/CET Reviewer Staging")
        }
        create("prod") {
            dimension = "default"
            applicationId = "com.aerol.csecet"
            resValue("string", "app_name", "CSE/CET Reviewer")
        }
    }

    buildTypes {
        release {
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
