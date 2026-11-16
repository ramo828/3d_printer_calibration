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

// JDK 17 ile çalışırken lint (lintVitalAnalyzeRelease) eklentilerde çöküyor:
// NoSuchMethodError: List.removeLast() (bu metot JDK 21+). Kalıcı çözüm Gradle'ı
// JDK 21 ile çalıştırmaktır; o zamana kadar release lint adımı atlanır.
subprojects {
    tasks.matching { it.name.startsWith("lintVital") }.configureEach {
        enabled = false
    }
}
