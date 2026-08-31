# Hluboká analýza: octopuscli

## Základní informace
- **Cílová cesta:** $targetPath
- **Detekované technologie:** PowerShell, Shell, .NET
- **Počet skriptů:** 12

## Popis z README
This repository contains the Octopus CLI (`octo`) for [Octopus][1], a user-friendly DevOps tool for developers that supports release management, deployment automation, and operations runbooks. You can use it to create and deploy releases, create and push packages, and manage environments.

`octo` can be [downloaded from the Octopus downloads page][2].

## Documentation
- [octo][3]

## Issues
Please see [Contributing](CONTRIBUTING.md)

## Development
You need:
- VSCode or Visual Studio 15.3 to compile the solution
- dotnet core 2.1.302 SDK

Run `Build.cmd` to build, test and package the project. Do this before pushing as it will run the surface area tests as well,
which require approval on almost every change.

To release to Nuget, tag `master` with the next major, minor or patch number, [TeamCity](https://build.octopushq.com/project.html?projectId=OctopusDeploy_OctopusCLI&tab=projectOverview) will do the rest. Kick off the `Release: Deploy OctopusCLI` build again if any of the dependencies fail.

Every successful TeamCity build for all branches will be pushed to Feedz.io.

## Compatibility
See the [Compatibility][4] page in our docs

[1]: https://octopus.com
[2]: https://octopus.com/downloads
[3]: https://octopus.com/docs/api-and-integration/octo.exe-command-line
[4]: https://octopus.com/docs/api-and-integration/compatibility


## Seznam skriptů
- `tools\octopuscli\BuildAssets\repos\test-linux-package-from-feed-in-dists.sh` – !/bin/bash
- `tools\octopuscli\BuildAssets\repos\test-linux-package-from-feed.sh` – !/bin/bash
- `tools\octopuscli\BuildAssets\create-octopuscli-linux-packages.sh` – !/bin/bash
- `tools\octopuscli\BuildAssets\init.ps1` – Skript init.ps1
- `tools\octopuscli\BuildAssets\octo.cmd` – Skript octo.cmd
- `tools\octopuscli\BuildAssets\OctoWrapper.sh` – !/bin/bash
- `tools\octopuscli\BuildAssets\test-linux-package-in-dists.sh` – !/bin/bash
- `tools\octopuscli\BuildAssets\test-linux-package.sh` – !/bin/bash
- `tools\octopuscli\source\Octo\init.ps1` – Skript init.ps1
- `tools\octopuscli\build.cmd` – Skript build.cmd
- `tools\octopuscli\build.ps1` – Skript build.ps1
- `tools\octopuscli\build.sh` – !/usr/bin/env bash


## Hodnocení a doporučení
<!-- Doplňte na základě výše uvedených informací -->
- 
