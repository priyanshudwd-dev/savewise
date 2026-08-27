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
    afterEvaluate {
        if (project.hasProperty("android")) {
            val androidObj = project.extensions.findByName("android")
            androidObj?.javaClass?.methods?.find { it.name == "compileSdkVersion" && it.parameterTypes.size == 1 }?.invoke(androidObj, 36)
        }
    }
}
