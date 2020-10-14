

switch ("$args[0]")
{
    "clean" {
        Remove-Item -Force -Recurse ingredients
        Remove-Item -Force -Recurse launcher
    } 
    Default {"Unknown command. dead."}
}