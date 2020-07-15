---
title: "GraalVM/nativeimage cross compilation with github Actions"
date: 2020-07-15T15:35:10+02:00
draft: true
---

# Introduction

GraalVM (https://www.graalvm.org/) allows to compile Java programs into native code with the `native-image` executable. One drawback of `native-image` is that it doesn't support cross-compilation. That means that you have to run `native-image` on all platforms that your Java program supports. I will show you in this article how you can automate this tedious task with github actions.

# Setup your gradle build 

In this article,  we will use the popular [gradle](https://gradle.org/) build tool together with the [Palantir GraalVM gradle plugin](https://github.com/palantir/gradle-graal). This setup will download the GraalVM toolchain, cache it locally and thus makes it very easy to use. This plugin is available from the gradle plugin and central and this makes it very easy to integrate it into our `gradle.build` file:

``` gradle
plugins {
    id 'com.palantir.graal' version '0.7.1'
}
```
Then you can add the following entries to your modules `build.gradle` to configure the `nativeImage` gradle task:
``` gradle
apply plugin: 'com.palantir.graal'

graal {
    graalVersion '20.0.0'
    outputName 'cross-compile-demo'
    mainClass 'com.maschinenstuermer.crosscompile.demo.App'
}
```

# Build your first native executable

After this setup, building your first native executable is as simple as typing `./gradlew nativeImage`. This will download the graal toolchain to your computer, execute the `native-image` compiler and then generate the executable to `/build/graal/cross-compile-demo`.

Running this executable then outputs the classical:
```
Hello world.
```

# Cross-compiling with Github Actions

# Conclusion

You can find the source code for this article here: https://github.com/katmatt/cross-compile-gh-actions

