param (
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,

    [Parameter(Mandatory = $true)]
    [string]$ContainerName,

    [Parameter(Mandatory = $true)]
    [string]$AccountKey,

    [Parameter(Mandatory = $true)]
    [string]$FileName,

    [Parameter(Mandatory = $false)]
    [string]$localTargetDirectory = "C:\Temp"
)

Write-Host "Mount Script execution started"

Write-Host "Mount Script - Installing modules"
# Install the packages required
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module Az.Storage -Force
Write-Host "Mount Script - Installing modules completed"

$ConnectionString = "DefaultEndpointsProtocol=https;AccountName=$StorageAccountName;AccountKey=$AccountKey"
$Ctx = New-AzStorageContext -ConnectionString $ConnectionString

if (Test-Path "$($localTargetDirectory)") {
    Write-Host "Removing existing folder $($localTargetDirectory)"
    Remove-Item -Path "$($localTargetDirectory)" -Recurse -Force
    Write-Host "Removed existing project folder $($localTargetDirectory)"
}

if (Test-Path "$($localTargetDirectory)_Extracted") {
    Write-Host "Removing existing folder $($localTargetDirectory)_Extracted"
    Remove-Item -Path "$($localTargetDirectory)_Extracted" -Recurse -Force
    Write-Host "Removed existing project folder $($localTargetDirectory)_Extracted"
}

New-Item -Path "C:\" -Name "Temp" -ItemType "directory" -Force
New-Item -Path "C:\" -Name "Temp_Extracted" -ItemType "directory" -Force

Write-Host "Mount Script - Downloading Blob to the Destination Path - $($localTargetDirectory)"
Get-AzStorageBlobContent -Blob $FileName -Container $ContainerName -Destination "$($localTargetDirectory)" -Context $Ctx -Force
Write-Host "Mount Script - Downloaded Blob to the Destination Path - $($localTargetDirectory)"

Write-Host "Mount Script - Extracting the downloaded file"
Expand-Archive -Path "$($localTargetDirectory)\$($FileName)" -DestinationPath "$($localTargetDirectory)_Extracted"
Write-Host "Mount Script - Extracted the downloaded file"

Set-Location "$($localTargetDirectory)_Extracted"

Write-Host "Mount Script execution completed"