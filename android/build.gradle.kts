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
// on_audio_query_android_v1_8 (transitive, via on_audio_query_forked) ships with
// compileSdk 33 hardcoded in its own build.gradle while depending on androidx
// libraries that require compileSdk 34+, which fails AGP's checkDebugAarMetadata.
// Force every subproject (plugin module) to compile against the same SDK as :app.
// Must be registered before evaluationDependsOn(":app") below forces evaluation.
subprojects {
    afterEvaluate {
        extensions.findByName("android")?.let { ext ->
            (ext as com.android.build.gradle.BaseExtension).compileSdkVersion(36)
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
