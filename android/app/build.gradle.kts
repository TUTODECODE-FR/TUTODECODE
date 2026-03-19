import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// ── Charger key.properties ────────────────────────────────────────────────
val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
}


android {
    namespace = "com.tutodecode.app"
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
        applicationId = "com.tutodecode.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ── Signing configs ───────────────────────────────────────────────────
    signingConfigs {
        // Config release (keystore depuis key.properties)
        if (keyPropertiesFile.exists()) {
            create("release") {
                keyAlias     = keyProperties["keyAlias"].toString()
                keyPassword  = keyProperties["keyPassword"].toString()
                storeFile    = file(keyProperties["storeFile"].toString())
                storePassword = keyProperties["storePassword"].toString()
            }
        }
    }

    buildTypes {
        // Debug : clé debug Flutter (inchangé)
        debug {
            signingConfig = signingConfigs.getByName("debug")
            isDebuggable  = true
        }
        // Release : notre keystore de production
        release {
            signingConfig = if (keyPropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // ACTIVÉ: Réduction massive de la taille du code et des ressources (R8)
            isMinifyEnabled   = true
            isShrinkResources = true
        }
    }

    // [DÉSACTIVÉ POUR RÉDUIRE LE POIDS]
    // Conserver les symboles de debug fait exploser la taille de l'APK à +400Mo.
    // Laissez désactivé, surtout pour la compilation sur GitHub Actions.
    /*
    packaging {
        jniLibs {
            keepDebugSymbols += listOf("**/*.so")
        }
    }
    */
}

flutter {
    source = "../.."
}
