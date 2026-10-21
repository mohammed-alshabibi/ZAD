allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// mapbox_maps_flutter only applies the Kotlin plugin on AGP < 9 (it expects
// AGP 9's built-in Kotlin), but this project keeps android.builtInKotlin=false.
// Apply it here, right after the Android library plugin, so its `kotlin { }`
// block works.
subprojects {
    if (name == "mapbox_maps_flutter_mobile") {
        plugins.withId("com.android.library") {
            pluginManager.apply("org.jetbrains.kotlin.android")
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
