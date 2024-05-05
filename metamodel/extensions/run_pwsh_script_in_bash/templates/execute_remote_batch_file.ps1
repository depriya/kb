param (
    [Parameter(Mandatory = $true)]
    [string]$FileName,

    [Parameter(Mandatory = $false)]
    [string]$localTargetDirectory = "C:\Temp"
)

Write-Host "Hello World $($FileName)"