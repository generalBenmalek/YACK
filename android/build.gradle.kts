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
subprojects {
    project.evaluationDependsOn(":app")
}

// Workaround AGP namespace requirement for third-party Android library modules (e.g., isar_flutter_libs)
// Some plugins don't declare `namespace` in their build files. This block sets a safe default.
subprojects {
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.api.dsl.LibraryExtension>("android") {
            if (namespace == null || namespace!!.isBlank()) {
                // Derive a deterministic namespace based on project name
                val safeName = project.name.replace('-', '_')
                namespace = "com.yack.autogen.$safeName"
            }
        }
    }
}

// Strip deprecated manifest package attribute from problematic plugins (e.g., isar_flutter_libs)
subprojects {
    if (name == "isar_flutter_libs") {
        afterEvaluate {
            val manifestFile = file("${project.projectDir}/src/main/AndroidManifest.xml")
            if (manifestFile.exists()) {
                val original = manifestFile.readText()
                // Remove any `package="..."` attribute from the <manifest> tag
                val patched = original.replace(Regex("[\\t\\r\\n ]+package=\"[^\"]+\""), "")
                if (patched != original) {
                    manifestFile.writeText(patched)
                    println("Patched manifest for isar_flutter_libs: removed package attribute")
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

