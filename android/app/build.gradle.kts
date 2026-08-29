import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
if (keyPropertiesFile.exists()) {
    keyPropertiesFile.inputStream().use { keyProperties.load(it) }
}

// A key.properties that exists but is missing fields is treated the same as
// no file at all: the release signingConfig is left unconfigured (so we never
// call file(null) during the configuration phase and crash unrelated builds
// like `flutter run`), and the whenReady guard below fails release builds with
// a message naming what's missing.
val requiredSigningKeys = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
val missingSigningKeys = requiredSigningKeys.filter { keyProperties.getProperty(it).isNullOrBlank() }
val hasReleaseSigningConfig = keyPropertiesFile.exists() && missingSigningKeys.isEmpty()

android {
    namespace = "com.smaraaccounting.smara_accounting"
    // flutter.compileSdkVersion is 36 in Flutter 3.47; flutter_secure_storage
    // 11 compiles against 37 and its AAR metadata forces every consumer to do
    // the same. Pin explicitly until the Flutter SDK default catches up.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.smaraaccounting.smara_accounting"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (hasReleaseSigningConfig) {
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
                storeFile = file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

gradle.taskGraph.whenReady {
    val assemblingRelease =
        gradle.taskGraph.allTasks.any { task ->
            val name = task.name
            name.contains("Release", ignoreCase = true) &&
                (
                    name.startsWith("assemble") ||
                        name.startsWith("bundle") ||
                        name.startsWith("package")
                )
        }
    if (assemblingRelease && !hasReleaseSigningConfig) {
        val problem =
            if (!keyPropertiesFile.exists()) {
                "Missing android/key.properties."
            } else {
                "android/key.properties is incomplete (missing or blank: " +
                    "${missingSigningKeys.joinToString(", ")})."
            }
        throw GradleException(
            "$problem Release builds must be signed with the upload keystore " +
                "named in that file, not the shared debug keystore. Copy " +
                "android/key.properties.example, fill in the four fields, and " +
                "keep both the properties file and the .jks/.keystore outside " +
                "version control. See docs/release/android-upload-keystore.md.",
        )
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
