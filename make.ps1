
param ($option)

switch ("$option")
{
    "create-sign" {
        & 'C:\Program Files (x86)\Windows Kits\10\bin\x64\makecert.exe' -r -h 0 -n "CN=23596F84-C3EA-4CD8-A7DF-550DCE37BCD0" -eku "1.3.6.1.5.5.7.3.3,1.3.6.1.4.1.311.10.3.13" -pe -sv .\launcher\DistroLauncher-Appx\DistroLauncher-Appx_TemporaryKey.pvk .\launcher\DistroLauncher-Appx\DistroLauncher-Appx_TemporaryKey.cer
        & 'C:\Program Files (x86)\Windows Kits\10\bin\x64\pvk2pfx' -pvk .\launcher\DistroLauncher-Appx\DistroLauncher-Appx_TemporaryKey.pvk -spc .\launcher\DistroLauncher-Appx\DistroLauncher-Appx_TemporaryKey.cer -pfx .\launcher\DistroLauncher-Appx\DistroLauncher-Appx_TemporaryKey.pfx
    }
    "all-17" {
        & 'C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\msbuild.exe' .\launcher\DistroLauncher.sln /t:Build /m /nr:false /p:Configuration=Release /p:AppxBundle=Always /p:AppxBundlePlatforms="x64|ARM64" /p:UapAppxPackageBuildMode=StoreUpload
    }
    "x64-only-17" {
        & 'C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\msbuild.exe' .\launcher\DistroLauncher.sln /t:Build /m /nr:false /p:Configuration=Release /p:AppxBundle=Always /p:Platform=x64 /p:UapAppxPackageBuildMode=StoreUpload
    }
    "all" {
        & 'C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe' .\launcher\DistroLauncher.sln /t:Build /m /nr:false /p:Configuration=Release /p:AppxBundle=Always /p:AppxBundlePlatforms="x64|ARM64" /p:UapAppxPackageBuildMode=StoreUpload
    }
    "x64-only" {
        & 'C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe' .\launcher\DistroLauncher.sln /t:Build /m /nr:false /p:Configuration=Release /p:AppxBundle=Always /p:Platform=x64 /p:UapAppxPackageBuildMode=StoreUpload
    }
    "clean" {
        Remove-Item -Force -Recurse ingredients
        Remove-Item -Force -Recurse launcher
        "Removed."
    } 
    Default {"Unknown command. dead."}
}