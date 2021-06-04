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

## Requirement

Following is the requirement of building environment:

- WSL and Virutal Machine Platform enabled (Windows 10 v1903 or higher)
- Visual Studio Community 2019
    - Universal Windows Platform Support
        - Windows 10 SDK (10.0.16299) and all higher SDKs
        - C++ Universal Windows Platform tools
    - Desktop Development with C++
        - VC++ 2019 v142 tools
        - C++ Profiling tools
        - Visual C++ tools for CMake

## Build

Run `.\cook.ps1 -Release <release> -PublishId <Publish ID>` to build.

For `insider`, Additional location for the custom built images should be passed with `-InsiderImageLocation` or `-InsiderImageUrl`.

For Custom ingredient used, please pass `-IngredientUrl`. Use `-IngredientBranch` to specify custom ingredient.

## Analysis

Pass `-PrepareOnly` when analysing the generated `launcher` code.

`launcher` should be built and handled with `.\make.ps1`.

- `.\make.ps1 all` to build arm64/amd64 appxbundle.
- `.\make.ps1 x64-only` to build amd64 appxbundle.
- `.\make.ps1 clean` to remove the files downloaded/generated for build.
