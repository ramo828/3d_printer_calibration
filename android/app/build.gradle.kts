plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Key.properties güvenli yükleme
import java.util.Properties

val keystoreProperties = Properties()
val keystorePropertiesFile = file("/home/ramo828/Documents/FlutterProjects/3d_printer_calibration/key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
} else {
    println("⚠️ key.properties dosyası bulunamadı! Release imzası yapılamayabilir.")
}

android {
    namespace = "com.ramosoft.pensiya_kalkulyatoru"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true // Düzeltildi: "is" eklendi
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"]?.toString()
            keyPassword = keystoreProperties["keyPassword"]?.toString()
            val storeFilePath = keystoreProperties["storeFile"]?.toString()
            if (storeFilePath != null) {
                storeFile = file(storeFilePath)
            }
            storePassword = keystoreProperties["storePassword"]?.toString()
        }
    }

    defaultConfig {
        applicationId = "com.ramosoft.pensiya_kalkulyatoru"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 2
        versionName = "2.0.0"

        ndk {
            abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a", "x86", "x86_64"))
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isShrinkResources = true
            isMinifyEnabled = true
            // ProGuard kuralları şu an yorum satırında, gerekirse aç
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.android.gms:play-services-ads:24.6.0")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}