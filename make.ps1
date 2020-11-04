
param ($option)

switch ("$option")
{
    "create-sign" {
        & 'C:\Program Files (x86)\Windows Kits\10\bin\x64\makecert.exe' -r -h 0 -n "CN=23596F84-C3EA-4CD8-A7DF-550DCE37BCD0" -eku "1.3.6.1.5.5.7.3.3,1.3.6.1.4.1.311.10.3.13" -pe -sv .\launcher\DistroLauncher-Appx\DistroLauncher-Appx_TemporaryKey.pvk .\launcher\DistroLauncher-Appx\DistroLauncher-Appx_TemporaryKey.cer
        & 'C:\Program Files (x86)\Windows Kits\10\bin\x64\pvk2pfx' -pvk .\launcher\DistroLauncher-Appx\DistroLauncher-Appx_TemporaryKey.pvk -spc .\launcher\DistroLauncher-Appx\DistroLauncher-Appx_TemporaryKey.cer -pfx .\launcher\DistroLauncher-Appx\DistroLauncher-Appx_TemporaryKey.pfx
    }
    "clean" {
        Remove-Item -Force -Recurse ingredients
        Remove-Item -Force -Recurse launcher
        "Removed."
    } 
    Default {"Unknown command. dead."}
}