pluginManagement {
    val flutterSdkPath = File(System.getProperty("user.home") + "/flutter")
        .takeIf { it.exists() }?.absolutePath
        ?: System.getenv("FLUTTER_SDK")
        ?: File(settingsDir.parentFile, "flutter").takeIf { it.exists() }?.absolutePath
        ?: File("C:/flutter/src/flutter").takeIf { it.exists() }?.absolutePath
        ?: throw GradleException("Flutter SDK not found at C:/flutter/src/flutter")

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.2.2" apply false
    id("org.jetbrains.kotlin.android") version "1.9.20" apply false
}

include(":app")