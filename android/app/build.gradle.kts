import java.util.Properties

plugins {
    id("com.android.application")
    // Built-in Kotlin: kotlin-android eklentisi artık gerekmiyor
    // Flutter Gradle eklentisi, Android eklentisinden sonra gelmeli
    id("dev.flutter.flutter-gradle-plugin")
}

// key.properties: önce android/ içine, yoksa android/app/ içine bakar.
// (Eski kodda iki arama da aynı yola bakıyordu; dosya android/app/ içinde
// olduğu için hiç bulunmuyor ve release build debug anahtarıyla imzalanıyordu.)
val keystoreProperties = Properties()
val keystorePropertiesFile = listOf(
    rootProject.file("key.properties"),
    file("key.properties"),
).firstOrNull { it.exists() }
val hasReleaseKey = keystorePropertiesFile != null

if (keystorePropertiesFile != null) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
} else {
    println("⚠️ key.properties dosyası bulunamadı! Release build debug anahtarıyla imzalanacak.")
}

android {
    namespace = "com.ramosoft.calibration_3d"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    if (hasReleaseKey) {
        signingConfigs {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storePassword = keystoreProperties.getProperty("storePassword")
                keystoreProperties.getProperty("storeFile")?.let {
                    storeFile = file(it)
                }
            }
        }
    }

    defaultConfig {
        applicationId = "com.ramosoft.calibration_3d"
        minSdk = 36
        targetSdk = flutter.targetSdkVersion
        versionCode = 8
        versionName = "2.1.4"
        // abiFilters kaldırıldı: Flutter ABI'leri kendisi yönetir,
        // --split-per-abi ile çakışıp build hatası verebilir.
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
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

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
