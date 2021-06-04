
param ($option, $publish)
if (!$publish) {
    $publish = "CN=Windows Console Dev Team"
}

$CertStore = "Cert:\CurrentUser\My"

switch ("$option")
{
    "create-sign" {
        Get-ChildItem $CertStore | Where-Object { $_.Subject -match $publish } | Remove-Item
        $TmpTP = (New-SelfSignedCertificate -Type Custom -Subject $publish -KeyUsage DigitalSignature -FriendlyName "Ubuntu Test Certificate" -CertStoreLocation "$CertStore" -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3","2.5.29.19={text}")).Thumbprint
        "$TmpTP"
    }
    "all-17" {
        & 'C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\msbuild.exe' .\launcher\DistroLauncher.sln /t:Build /m /nr:false /p:Configuration=Release /p:AppxBundle=Always /p:AppxBundlePlatforms="x64|ARM64" /p:UapAppxPackageBuildMode=StoreUpload
    }
    "x64-only-17" {
        & 'C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\msbuild.exe' .\launcher\DistroLauncher.sln /t:Build /m /nr:false /p:Configuration=Release /p:AppxBundle=Always /p:Platform=x64 /p:UapAppxPackageBuildMode=StoreUpload
    }
    "all-upload" {
        & 'C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe' .\launcher\DistroLauncher.sln /t:Build /m /nr:false /p:Configuration=Release /p:AppxBundle=Always /p:AppxBundlePlatforms="x64|ARM64" /p:UapAppxPackageBuildMode=StoreUpload
    }
    "all" {
        & 'C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe' .\launcher\DistroLauncher.sln /t:Build /m /nr:false /p:Configuration=Release /p:AppxBundle=Always /p:AppxBundlePlatforms="x64|ARM64"
    }
    "x64-only" {
        & 'C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe' .\launcher\DistroLauncher.sln /t:Build /m /nr:false /p:Configuration=Release /p:AppxBundle=Always /p:Platform=x64
    }
    "clean" {
        Remove-Item -Force -Recurse ingredients
        Remove-Item -Force -Recurse launcher
        "Removed."
    } 
    Default {"Unknown command. dead."}
}