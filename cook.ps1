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

function Find-AndInsertAfter {
    $Match = [regex]::Escape($args[1])
    $NewLine = $args[2]
    $Content = Get-Content $args[0]
    $Index = ($content | Select-String -Pattern $Match).LineNumber
    $NewContent = @()
    0..($Content.Count - 1) | Foreach-Object {
        if ($_ -eq $index) {
            $NewContent += $NewLine
        }
        $NewContent += $Content[$_]
    }
    $NewContent | Out-File $args[0]
}

function Find-AndReplace {
    (Get-Content $args[0]).replace($args[1], $args[2]) | Set-Content $args[0]
}

$arch_linux2win = @{ amd64 = "x64"; arm64 = "ARM64" }
#importing definitions to be used for build
Write-Host "# Checking power..." -ForegroundColor DarkYellow

$ARamdomTable = Import-Csv .\def.csv | Where-Object rel -eq "$Release"

If ($ARamdomTable.rel -eq $null) {throw ""}

$ReleaseChannel = $ARamdomTable.rel
$Release = $ARamdomTable.code
$ExecName = $ARamdomTable.name
$FullName = $ARamdomTable.full_rel
$RelVersion = $ARamdomTable.ver
$RegName = $FullName.replace(' LTS', '').replace(" ", "-")
$PkgName = "CanonicalGroupLimited.$($FullName.replace(' LTS', '').replace(" ", ''))onWindows"
$PkgVersion = "$RelVersion.$(get-date -Format yyyy.Mdd).0"
Write-Host "#####################" -ForegroundColor Green
Write-Host "# $ReleaseChannel Channel" -ForegroundColor Green
Write-Host "#####################" -ForegroundColor Green
Write-Host "# Version: $RelVersion" -ForegroundColor Green
Write-Host "# Codename: $Release" -ForegroundColor Green
Write-Host "# Executable Name: $ExecName.exe" -ForegroundColor Green
Write-Host "# Registered Name: $RegName" -ForegroundColor Green
Write-Host "# -------------------" -ForegroundColor Green
Write-Host "# UWP SECTION" -ForegroundColor Green
Write-Host "# Full Name: $FullName" -ForegroundColor Green
Write-Host "# Package Name: $PkgName" -ForegroundColor Green
Write-Host "# Package Name: $PkgVersion" -ForegroundColor Green

# checking whether these executables exist
Write-Host "# Getting cooker ready..." -ForegroundColor DarkYellow

Import-Module C:\Users\Patrick\Git\PsUWI\PsUWI.psd1
#Import-Module PsUWI

$build_instance = New-UbuntuWSLInstance -Release focal -Version 2 -AdditionalPkg "git,wget,make,icoutils,inkscape" -NonInteractive
wsl.exe -d ubuntu-$build_instance echo -e `"`[automount`]\noptions `= `"metadata`"`" `>`> /etc/wsl.conf
wsl.exe -t ubuntu-$build_instance
function Run-WithInstance { wsl.exe -d ubuntu-$build_instance -u $env:USERNAME $args }

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

    # root folder
    Find-AndReplace .\launcher\DistroLauncher.sln '"DistroLauncher-Appx"' '"Ubuntu"'
    Find-AndReplace .\launcher\DistroLauncher.sln 'DistroLauncher-Appx.' 'Ubuntu.'

    # DistroLauncher
    Find-AndReplace .\launcher\DistroLauncher\DistributionInfo.h 'MyDistribution' "$RegName"
    Find-AndReplace .\launcher\DistroLauncher\DistributionInfo.h 'My Distribution' "$FullName"

    #DistroLauncherAppx
    Rename-Item -Path .\launcher\DistroLauncher-Appx\DistroLauncher-Appx.vcxproj -NewName Ubuntu.vcxproj
    Rename-Item -Path .\launcher\DistroLauncher-Appx\DistroLauncher-Appx.vcxproj.filters -NewName Ubuntu.vcxproj.filters

    Find-AndReplace .\launcher\DistroLauncher-Appx\Ubuntu.vcxproj.filters 'MyDistro.appxmanifest' '$(Platform)/Ubuntu.appxmanifest'

    Find-AndReplace .\launcher\DistroLauncher-Appx\Ubuntu.vcxproj 'MyDistro.appxmanifest' '$(Platform)/Ubuntu.appxmanifest'
    Find-AndReplace .\launcher\DistroLauncher-Appx\Ubuntu.vcxproj '10.0.16215.0' '10.0.16237.0'
    Find-AndReplace .\launcher\DistroLauncher-Appx\Ubuntu.vcxproj 'MyDistro.appxmanifest' '$(Platform)/Ubuntu.appxmanifest'
    Find-AndReplace .\launcher\DistroLauncher-Appx\Ubuntu.vcxproj 'mydistro' "$ExecName"
    Find-AndReplace .\launcher\DistroLauncher-Appx\Ubuntu.vcxproj '<ProjectName>DistroLauncher-Appx</ProjectName>' '<ProjectName>Ubuntu</ProjectName>'
    Find-AndReplace .\launcher\DistroLauncher-Appx\Ubuntu.vcxproj '<AppxAutoIncrementPackageRevision>True</AppxAutoIncrementPackageRevision>' ''
    Find-AndInsertAfter .\launcher\DistroLauncher-Appx\Ubuntu.vcxproj '<AppxBundlePlatforms>x64|arm64</AppxBundlePlatforms>' '    <AppxSymbolPackageEnabled>True</AppxSymbolPackageEnabled>'

    Find-AndReplace .\launcher\DistroLauncher-Appx\MyDistro.appxmanifest ' Name="WSL-DistroLauncher"' " Name=`"$PkgName`""
    Find-AndReplace .\launcher\DistroLauncher-Appx\MyDistro.appxmanifest 'Version="1.0.0.0"' "Version=`"$PkgVersion`""
    Find-AndReplace .\launcher\DistroLauncher-Appx\MyDistro.appxmanifest 'CN=Windows Console Dev Team' 'CN=23596F84-C3EA-4CD8-A7DF-550DCE37BCD0'
    Find-AndReplace .\launcher\DistroLauncher-Appx\MyDistro.appxmanifest 'ProcessorArchitecture="x64"' 'ProcessorArchitecture="ARCHITECTUREPLACEHOLDER"'
    Find-AndReplace .\launcher\DistroLauncher-Appx\MyDistro.appxmanifest 'WSL-DistroLauncher' "$FullName"
    Find-AndReplace .\launcher\DistroLauncher-Appx\MyDistro.appxmanifest 'Windows Console Dev Team' 'Canonical Group Limited'
    Find-AndReplace .\launcher\DistroLauncher-Appx\MyDistro.appxmanifest 'mydistro' "$ExecName"
    Find-AndReplace .\launcher\DistroLauncher-Appx\MyDistro.appxmanifest 'My Own Distro Launcher' "$FullName on Windows"
    Find-AndInsertAfter .\launcher\DistroLauncher-Appx\MyDistro.appxmanifest '<uap:DefaultTile Wide310x150Logo="Assets\Wide310x150Logo.png" Square310x310Logo="Assets\LargeTile.png" Square71x71Logo="Assets\SmallTile.png">' '<uap:ShowNameOnTiles><uap:ShowOn Tile="square150x150Logo" /></uap:ShowNameOnTiles>'
    Find-AndReplace .\launcher\DistroLauncher-Appx\MyDistro.appxmanifest '<uap:DefaultTile Wide310x150Logo="Assets\Wide310x150Logo.png" Square310x310Logo="Assets\LargeTile.png" Square71x71Logo="Assets\SmallTile.png">' "<uap:DefaultTile Wide310x150Logo=`"Assets\Wide310x150Logo.png`" Square310x310Logo=`"Assets\LargeTile.png`" Square71x71Logo=`"Assets\SmallTile.png`" ShortName=`"$FullName`">"
    Find-AndReplace .\launcher\DistroLauncher-Appx\MyDistro.appxmanifest 'transparent' '#E95420'
    Find-AndReplace .\launcher\DistroLauncher-Appx\MyDistro.appxmanifest '10.0.16215.0' '10.0.16237.0'

    # preparing the build!
    foreach ($arch in @('amd64', 'arm64')) {
        if ( ( $Release -eq "xenial" ) -and ( $arch -eq "arm64" )) {
            break
        }
        $ArchFolderName = $arch_linux2win["$arch"]
        if ( -not (Test-Path -Path ".\launcher\DistroLauncher-Appx\$ArchFolderName" -PathType Container ) ) {
            mkdir -Path ".\launcher\DistroLauncher-Appx\$ArchFolderName" | Out-Null
        }
        Copy-Item .\launcher\DistroLauncher-Appx\MyDistro.appxmanifest ".\launcher\DistroLauncher-Appx\$ArchFolderName\Ubuntu.appxmanifest"
        Find-AndReplace ".\launcher\DistroLauncher-Appx\$ArchFolderName\Ubuntu.appxmanifest" 'ARCHITECTUREPLACEHOLDER' "$($ArchFolderName.ToLower())"
    }

    Write-Host "# Cooking Rice..." -ForegroundColor DarkYellow

    if ( -not (Test-Path -Path ".\launcher\DistroLauncher-Appx\DistroLauncher-Appx_TemporaryKey.pfx" -PathType Leaf) ) {
        & 'C:\Program Files (x86)\Windows Kits\10\bin\x64\makecert.exe' -r -h 0 -n "CN=23596F84-C3EA-4CD8-A7DF-550DCE37BCD0" -eku "1.3.6.1.5.5.7.3.3,1.3.6.1.4.1.311.10.3.13" -pe -sv .\launcher\DistroLauncher-Appx\DistroLauncher-Appx_TemporaryKey.pvk .\launcher\DistroLauncher-Appx\DistroLauncher-Appx_TemporaryKey.cer
        & 'C:\Program Files (x86)\Windows Kits\10\bin\x64\pvk2pfx' -pvk .\launcher\DistroLauncher-Appx\DistroLauncher-Appx_TemporaryKey.pvk -spc .\launcher\DistroLauncher-Appx\DistroLauncher-Appx_TemporaryKey.cer -pfx .\launcher\DistroLauncher-Appx\DistroLauncher-Appx_TemporaryKey.pfx
    }

    foreach ($arch in @('amd64', 'arm64')) {
        if ( ( $Release -eq "xenial" ) -and ( $arch -eq "arm64" )) {
            & 'C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\msbuild.exe' .\launcher\DistroLauncher.sln /t:Build /m /nr:true /p:Configuration=Release /p:AppxBundle=Always /p:Platform=x64 /p:UapAppxPackageBuildMode=StoreUpload
        }
        & 'C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\msbuild.exe' .\launcher\DistroLauncher.sln /t:Build /m /nr:true /p:Configuration=Release /p:AppxBundle=Always /p:AppxBundlePlatforms="x64|ARM64" /p:UapAppxPackageBuildMode=StoreUpload
    }
}
finally {
    Remove-UbuntuWSLInstance -Id $build_instance
    Remove-Item -Force -Recurse ingredients
    # Remove-Item -Force -Recurse launcher
}

