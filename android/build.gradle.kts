import com.android.build.gradle.BaseExtension

subprojects {
    afterEvaluate {
        extensions.findByType(BaseExtension::class.java)?.apply {
            compileSdkVersion(36)
        }
    }
}


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

    plugins.withId("com.android.library") {
        val android = project.extensions.getByType(com.android.build.gradle.LibraryExtension::class.java)
        if (android.namespace == null) {
            android.namespace = "com.example.${project.name.replace("-", "_")}"
        }
        
        project.afterEvaluate {
             android.sourceSets.getByName("main").manifest.srcFile.let { manifestFile ->
                 if (manifestFile.exists()) {
                     val content = manifestFile.readText()
                     if (content.contains("package=\"")) {
                         val newContent = content.replace(Regex("package=\"[^\"]+\""), "")
                         manifestFile.writeText(newContent)
                     }
                 }
             }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

