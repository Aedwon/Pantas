import java.io.File
import java.util.Properties
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val uploadSigningProperties = Properties()
val uploadSigningPropertiesFile = rootProject.file("key.properties")
if (uploadSigningPropertiesFile.exists()) {
    uploadSigningPropertiesFile.inputStream().use(uploadSigningProperties::load)
}

fun nonBlankEnvironment(name: String): String? =
    System.getenv(name)?.trim()?.takeIf { it.isNotEmpty() }

fun nonBlankSigningProperty(name: String): String? =
    uploadSigningProperties.getProperty(name)?.trim()?.takeIf { it.isNotEmpty() }

val cmKeystorePath = nonBlankEnvironment("CM_KEYSTORE_PATH")
val cmKeystorePassword = nonBlankEnvironment("CM_KEYSTORE_PASSWORD")
val cmKeyAlias = nonBlankEnvironment("CM_KEY_ALIAS")
val cmKeyPassword = nonBlankEnvironment("CM_KEY_PASSWORD")
val cmSigningValues =
    listOf(cmKeystorePath, cmKeystorePassword, cmKeyAlias, cmKeyPassword)
val anyCmSigningValue = cmSigningValues.any { it != null }
val completeCmSigning = cmSigningValues.all { it != null }

if (anyCmSigningValue && !completeCmSigning) {
    throw GradleException(
        "Codemagic upload signing is incomplete. Set all CM_KEYSTORE_* / CM_KEY_* inputs.",
    )
}

val localKeystorePath = nonBlankSigningProperty("storeFile")
val localKeystorePassword = nonBlankSigningProperty("storePassword")
val localKeyAlias = nonBlankSigningProperty("keyAlias")
val localKeyPassword = nonBlankSigningProperty("keyPassword")
val localSigningValues =
    listOf(localKeystorePath, localKeystorePassword, localKeyAlias, localKeyPassword)
val anyLocalSigningValue = localSigningValues.any { it != null }
val completeLocalSigning = localSigningValues.all { it != null }

if (anyLocalSigningValue && !completeLocalSigning) {
    throw GradleException(
        "android/key.properties upload signing is incomplete. Set storeFile, storePassword, keyAlias, and keyPassword.",
    )
}

val uploadKeystorePath =
    when {
        completeCmSigning -> cmKeystorePath
        completeLocalSigning -> localKeystorePath
        else -> null
    }
val uploadKeystorePassword =
    when {
        completeCmSigning -> cmKeystorePassword
        completeLocalSigning -> localKeystorePassword
        else -> null
    }
val uploadKeyAlias =
    when {
        completeCmSigning -> cmKeyAlias
        completeLocalSigning -> localKeyAlias
        else -> null
    }
val uploadKeyPassword =
    when {
        completeCmSigning -> cmKeyPassword
        completeLocalSigning -> localKeyPassword
        else -> null
    }

fun resolveKeystoreFile(path: String): File {
    val candidate = File(path)
    return if (candidate.isAbsolute) candidate else rootProject.file(path)
}

val uploadKeystoreFile = uploadKeystorePath?.let(::resolveKeystoreFile)
val uploadSigningReady =
    uploadKeystoreFile != null &&
        uploadKeystorePassword != null &&
        uploadKeyAlias != null &&
        uploadKeyPassword != null

val requestsProdRelease =
    gradle.startParameter.taskNames.any { taskName ->
        val normalized = taskName.lowercase()
        normalized.contains("prodrelease") ||
            (normalized.contains("prod") && normalized.contains("release"))
    }

if (requestsProdRelease) {
    if (!uploadSigningReady) {
        throw GradleException(
            "Production release signing is required. Configure android/key.properties or all Codemagic signing inputs.",
        )
    }
    if (uploadKeystoreFile == null || !uploadKeystoreFile.isFile) {
        throw GradleException("Production upload keystore file does not exist.")
    }
}

android {
    namespace = "com.aedwon.pantas"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications.
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("upload") {
            if (uploadSigningReady) {
                storeFile = uploadKeystoreFile
                storePassword = uploadKeystorePassword
                keyAlias = uploadKeyAlias
                keyPassword = uploadKeyPassword
            }
        }
    }

    defaultConfig {
        applicationId = "com.aedwon.pantas"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "default"
    productFlavors {
        create("dev") {
            dimension = "default"
            applicationId = "com.aedwon.pantas.dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "Pantas Dev")
        }
        create("staging") {
            dimension = "default"
            applicationId = "com.aedwon.pantas.dev.staging"
            versionNameSuffix = "-staging"
            resValue("string", "app_name", "Pantas Staging")
        }
        create("prod") {
            dimension = "default"
            applicationId = "com.aedwon.pantas"
            resValue("string", "app_name", "Pantas")
            signingConfig = signingConfigs.getByName("upload")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
