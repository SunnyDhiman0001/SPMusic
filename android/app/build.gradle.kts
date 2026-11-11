
import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

// Load signing credentials
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

// Play Console rejects any versionCode it has already seen, so the code is
// generated per build instead of being copied from pubspec's "+N" (which must
// be bumped by hand). It is minutes since 2025-01-01 UTC: always increasing,
// unique for every build, and far below Play's 2,100,000,000 limit.
// Set the VERSION_CODE environment variable to force a specific value.
val autoVersionCode: Int = System.getenv("VERSION_CODE")?.toIntOrNull()
    ?: ((System.currentTimeMillis() - 1_735_689_600_000L) / 60_000L).toInt()

android {
    namespace = "com.example.spmusic"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.spmusic.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = autoVersionCode
        versionName = flutter.versionName
    }

    // Release signing configuration
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
