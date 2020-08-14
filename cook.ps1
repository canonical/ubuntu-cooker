[cmdletbinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Release,
    [Parameter(Mandatory = $false)]
    [string]$BaseImgUrl = "https://cloud-images.ubuntu.com",
    [Parameter(Mandatory = $false)]
    [string]$LauncherUrl = "https://github.com/microsoft/WSL-DistroLauncher",
    [Parameter(Mandatory = $false)]
    [string]$IngredientUrl = "git@github.com:patrick330602/ubuntu-cooker-ingredients"
)

$arch_linux2win = @{ amd64 = "x64"; arm64 = "ARM64" }
#importing definitions to be used for build
Write-Host "# Checking power..." -ForegroundColor DarkYellow

$ARamdomTable = Import-Csv .\def.csv | Where-Object rel -eq "$Release"
$ReleaseChannel = $ARamdomTable.rel
$Release = $ARamdomTable.code
$ExecName = $ARamdomTable.name
$FullName = $ARamdomTable.full_rel
$RelVersion = $ARamdomTable.ver
Write-Host "#####################" -ForegroundColor Green
Write-Host "# Channel: $ReleaseChannel" -ForegroundColor Green
Write-Host "# Version: $RelVersion" -ForegroundColor Green
Write-Host "# Codename: $Release" -ForegroundColor Green
Write-Host "# Executable Name: $ExecName.exe" -ForegroundColor Green
Write-Host "# Full Name: $FullName" -ForegroundColor Green

# checking whether these executables exist
Write-Host "# Getiing cooker ready..." -ForegroundColor DarkYellow

Import-Module C:\Users\Patrick\Git\PsUWI\PsUWI.psd1
#Import-Module PsUWI

$build_instance = New-UbuntuWSLInstance -Release focal -Version 2 -AdditionalPkg "git,wget,make,icoutils,inkscape" -NonInteractive
wsl.exe -d ubuntu-$build_instance echo -e `"`[automount`]\noptions `= `"metadata`"`" `>`> /etc/wsl.conf
wsl.exe -t ubuntu-$build_instance
function Run-WithInstance {wsl.exe -d ubuntu-$build_instance -u $env:USERNAME $args}

try {
    # getting the WSL Distro Launcher source
    Write-Host "# Putting Rice..." -ForegroundColor DarkYellow
    Run-WithInstance git clone $LauncherUrl launcher

    git.exe clone $IngredientUrl ingredients
    # Run-WithInstance git clone $IngredientUrl ingredients
    Set-Location ./ingredients
    Run-WithInstance DESTDIR=../launcher clean_remote
    Run-WithInstance make
    Run-WithInstance DESTDIR=../launcher make install
    Set-Location ..

    Write-Host "# Putting Water..." -ForegroundColor DarkYellow
    # foreach ($item in @('SHA256SUMS', 'SHA256SUMS.gpg')) {
    #     wget.exe $BaseImgUrl/$Release/current/$item
    # }
    # gpg.exe --verify SHA256SUMS.gpg SHA256SUMS

    foreach ($arch in @('amd64', 'arm64')) {
        if ( ( $Release -eq "xenial" ) -and ( $arch -eq "arm64" )) {
            break
        }
        $ArchFolderName = $arch_linux2win["$arch"]
        if ( -not (Test-Path -Path ".\launcher\$ArchFolderName" -PathType Container ) ) {
            mkdir -Path ".\launcher\$ArchFolderName" | Out-Null
        }
        Run-WithInstance wget $BaseImgUrl/$Release/current/$Release-server-cloudimg-$arch-wsl.rootfs.tar.gz
        Move-Item -Force $Release-server-cloudimg-$arch-wsl.rootfs.tar.gz .\launcher\$ArchFolderName\install.tar.gz
    }

    Write-Host "# Rinsing Rice..." -ForegroundColor DarkYellow

    (Get-Content .\launcher\DistroLauncher.sln).replace('"DistroLauncher-Appx"', '"Ubuntu"') | Set-Content .\launcher\DistroLauncher.sln
    (Get-Content .\launcher\DistroLauncher.sln).replace('DistroLauncher-Appx.', 'Ubuntu.') | Set-Content .\launcher\DistroLauncher.sln
    #(Get-Content .\launcher\DistroLauncher.sln).replace('DistroLauncher-Appx.', 'Ubuntu.') | Set-Content .\launcher\DistroLauncher.sln
}
finally {
    Remove-UbuntuWSLInstance -Id $build_instance
    # Remove-Item -Force -Recurse ingredients
    # Remove-Item -Force -Recurse launcher
}

