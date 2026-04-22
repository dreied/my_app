import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

android {
    namespace = "com.example.my_app"
    compileSdk = 36

   defaultConfig {
    applicationId = "com.example.my_app"
    minSdk = flutter.minSdkVersion
    targetSdk = 36

    versionCode = flutter.versionCode.toInt()
    versionName = flutter.versionName
}


    signingConfigs {
    create("release") {
        val alias = keystoreProperties["keyAlias"]?.toString()
        val password = keystoreProperties["keyPassword"]?.toString()
        val store = keystoreProperties["storeFile"]?.toString()
        val storePass = keystoreProperties["storePassword"]?.toString()

        if (alias != null && password != null && store != null && storePass != null) {
            keyAlias = alias
            keyPassword = password
            storeFile = file(store)
            storePassword = storePass
        }
    }
}


    buildTypes {
        getByName("debug") {
            applicationIdSuffix = ".debug"
        }

       getByName("release") {
    val releaseConfig = signingConfigs.findByName("release")

    // Only sign if keystore exists (local PC)
    if (releaseConfig?.storeFile != null) {
        signingConfig = releaseConfig
    } else {
        println("⚠️ No keystore found. Building unsigned release APK.")
    }

    isMinifyEnabled = true
    isShrinkResources = false

    proguardFiles(
        getDefaultProguardFile("proguard-android-optimize.txt"),
        "proguard-rules.pro"
    )
}

    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")

    implementation("androidx.camera:camera-core:1.3.0")
    implementation("androidx.camera:camera-camera2:1.3.0")
    implementation("androidx.camera:camera-lifecycle:1.3.0")
    implementation("androidx.camera:camera-view:1.3.0")
    implementation("androidx.camera:camera-extensions:1.3.0")
}

flutter {
    source = "../.."
}
