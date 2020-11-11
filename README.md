# Ubuntu Cooker

This is the automatic Ubuntu UWP build system that inspired by `ubuntu-old-hashioned` and `ubuntu-bartender`.

This allows autoamtic builds of Ubuntu for local builds and packages for upload.


## Build

Run `.\cook.ps1 -Release <release> -IngredientUrl <url to ingredient repository>` to build.

For `insider`, Additional location for the custom built images should be passed with `-InsiderImageLocation`.

## Analysis

Pass `-PrepareOnly` when analysing the generated launcher code.

Manual works should be built and handled with `.\make.ps1`. This script simulates `make` command.
