# Ubuntu Cooker

This is the automatic Ubuntu UWP build system that inspired by `ubuntu-old-hashioned` and `ubuntu-bartender`.

This allows autoamtic builds of Ubuntu UWP and it outputs local builds(`.appxbundle`) and upload-only packages(`.appxupload`).

This supports all the current releases on Microsoft Store:
- Ubuntu On Windows Community Preview (`insider`)
- Ubuntu on Windows (`lts`)
- Ubuntu 20.04 LTS (`focal`)
- Ubuntu 18.04 LTS (`bionic`)
- ~~Ubuntu 16.04 LTS (`xenial`)~~

\*: Ubuntu 16.04 LTS is hidden and soon be pulled from the store as it is EOL. Still keep the build script for possible future extended support.

## Reqauirement

Following is the requirement of building environment:

- WSL and Virutal Machine Platform enabled (Windows 10 v1903 or higher)
- Visual Studio Community 2017
    - Universal Windows Platform Support
        - Windows 10 SDK (10.0.15063) and all higher SDKs
        - C++ Universal Windows Platform tools
    - Desktop Development with C++
        - VC++ 2017 v141 tools
        - C++ Profiling tools
        - Visual C++ tools for CMake

## Build

Run `.\cook.ps1 -Release <release> -IngredientUrl <url to ingredient repository>` to build.

For `insider`, Additional location for the custom built images should be passed with `-InsiderImageLocation`.

## Analysis

Pass `-PrepareOnly` when analysing the generated launcher code.

Manual works should be built and handled with `.\make.ps1`. This script simulates `make` command.
