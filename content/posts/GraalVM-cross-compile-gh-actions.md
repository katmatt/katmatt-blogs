---
title: "GraalVM/native-image cross-compilation with github Actions"
date: 2020-07-15T15:35:10+02:00
draft: false
---

GraalVM (https://www.graalvm.org/) allows to compile Java programs into native code with the *native-image* executable. This gives Java developers new options because you can now release native executable for your users. And that brings Java to the world of easy to install command-line tools, which at the moment is one of the unique selling points of newer programming languages like Go or Rust. Both of these languages have dedicated support for cross-compiling programs/libraries to target architectures different from the host system. 

But one limitation of *native-image* is that it doesn't support cross-compilation out of the box (see open issue: [native-image: Cross compilation support?](https://github.com/oracle/graal/issues/407)). That means that you have to run *native-image* on all platforms that your Java program should support. 

This article will show you how you can use github actions to simplify this task by automating it. Then the only thing you have to do to trigger the release of native excutables of your program is to tag your release and push that tag to github.

## Setup your gradle build 

In this article,  we will use the popular [gradle](https://gradle.org/) build tool together with the [Palantir GraalVM gradle plugin](https://github.com/palantir/gradle-graal). This setup will download the GraalVM toolchain, cache it locally and thus makes it very easy to use. This plugin is available from the gradle plugin central and this makes it very easy to integrate it into our *gradle.build* file:

``` gradle
plugins {
    id 'com.palantir.graal' version '0.7.1'
}
```
Then you can add the following entries to your modules *build.gradle* to configure the *nativeImage* gradle task:
``` gradle
apply plugin: 'com.palantir.graal'

graal {
    graalVersion '20.0.0'
    outputName 'cross-compile-demo'
    mainClass 'com.maschinenstuermer.crosscompile.demo.App'
}
```

## Build your first native executable

After this setup, building your first native executable is as simple as running `./gradlew nativeImage`. This will download the graal toolchain to your computer, execute *native-image* and generate the executable to *build/graal/cross-compile-demo*.

Running this executable then outputs the classical:
```
Hello world.
```
The next step is to archive the executable into a zip file, which we later will upload to the github release. We do this by adding the following task to our *build.gradle* file:
``` gradle
task zipExecutable(type: Zip) {
    dependsOn 'nativeImage'
    
    archiveFileName = "cross-compile-demo.zip"
    destinationDirectory = file("$buildDir/dist")

    from "$buildDir/graal" 
}
```
With this additional task, we can now build and archive our executable by running `./gradlew zipExecutable`. This produces our zip file in the *build/dist* folder. You can see the full build file here: [build.gradle](https://github.com/katmatt/cross-compile-gh-actions/blob/master/build.gradle)

## Cross-compiling with Github Actions

Our release process is triggered when a user tags a release and pushes these tags to github. This is accomplished with the following trigger in our workflow file:
``` yaml
on:
  push:
    tags:
    - 'v*' # Push events to matching v*, i.e. v1.0, v20.15.10
```
Our workflow then creates a github release for this tag and stores the *upload_url* variable as an output that our downstream jobs can use to upload their artifacts with the following job definition :
``` yaml
jobs:
  create-release:
    runs-on: ubuntu-latest
    outputs:
      upload_url: ${{ steps.create-release.outputs.upload_url }}
    steps:
      - uses: actions/checkout@v2
      - name: Create Release
        id: create-release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ github.ref }}
          release_name: Release ${{ github.ref }}
          draft: false
          prerelease: false
```
We now add jobs for each supported operating system, which depends on our *create-release* job by setting the *needs:* facet to *create-release*. The following workflow defines the release build for linux:
``` yaml
  perform-release-linux:
    needs: create-release
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Set up JDK 1.8
      uses: actions/setup-java@v1
      with:
        java-version: 1.8
    - name: Grant execute permission for gradlew
      run: chmod +x gradlew
    - name: Build native image with Gradle
      run: ./gradlew zipExecutable
    - name: Upload Release Asset
      uses: actions/upload-release-asset@v1
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        upload_url: ${{ needs.create-release.outputs.upload_url }}  
        asset_path: ./build/dist/cross-compile-demo.zip
        asset_name: cross-compile-demo_linux_amd64.zip
        asset_content_type: application/zip
``` 
And this job references the *upload_url* output from our *create-release* job with the `${{ needs.create-release.outputs.upload_url }}` expression.
You can see the full workflow file here: [perform-release.yml](https://github.com/katmatt/cross-compile-gh-actions/blob/master/.github/workflows/perform-release.yml)

## Conclusion

This article showed you how you can leverage github actions to cross-compile your Java program for different target architectures. The presented solution works with an easy setup. But it has a drawback too: Our workflow downloads the GraalVM distribution for each platform on each release. And releasing our simple demo program took already 5 minutes. 

But if you compare this solution with running the cross-compilation manually - across several computers or virtual machines - and if your release frequency is daily or weekly, then this article provides a good enough solution. Our proposed solution could be further improved by using matrix builds or by caching the downloaded GraalVM distribution, so feel free to improve this solution further!

You can find the source code for this article here: https://github.com/katmatt/cross-compile-gh-actions

