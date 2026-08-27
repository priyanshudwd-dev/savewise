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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    project.configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "androidx.lifecycle") {
                useVersion("2.7.0")
            }
        }
    }
}

subprojects {
    val applySdkFix = {
        val androidObj = project.extensions.findByName("android")
        if (androidObj != null) {
            try {
                androidObj.javaClass.getMethod("compileSdkVersion", Int::class.javaPrimitiveType)?.invoke(androidObj, 36)
            } catch (_: Exception) {}
        }
    }

    if (project.state.executed) {
        applySdkFix()
    } else {
        project.afterEvaluate { applySdkFix() }
    }
}
