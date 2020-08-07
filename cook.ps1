[cmdletbinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Release,
    [Parameter(Mandatory = $false)]
    [string]$BaseImgUrl="https://cloud-images.ubuntu.com",
    [Parameter(Mandatory = $false)]
    [string]$LauncherUrl="https://github.com/microsoft/WSL-DistroLauncher"
)

$arch_linux2win = @{ amd64 = "x64"; arm64 = "ARM64"}

# checking whether these executables exist
Write-Host "# Checking power..." -ForegroundColor DarkYellow

foreach ($item in @('git.exe', 'wget.exe')) {
    if ((Get-Command "$item" -ErrorAction SilentlyContinue) -eq $null) 
    { 
       Write-Host "Unable to find gpg.exe in your PATH"
       exit 1
    }
}

# getting the WSL Distro Launcher source
Write-Host "# Putting Rice..." -ForegroundColor DarkYellow
git.exe clone $LauncherUrl launcher


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
    wget.exe $BaseImgUrl/$Release/current/$Release-server-cloudimg-$arch-wsl.rootfs.tar.gz
    Move-Item -Force $Release-server-cloudimg-$arch-wsl.rootfs.tar.gz .\launcher\$ArchFolderName\install.tar.gz
}
