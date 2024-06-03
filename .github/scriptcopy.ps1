param (
    [Parameter(Mandatory=$true)]
    [string]$StorageAccountName,

    [Parameter(Mandatory=$true)]
    [string]$ContainerName,

    [Parameter(Mandatory=$true)]
    [string]$AccountKey,

    [Parameter(Mandatory=$true)]
    [string]$JfrogToken,

    [Parameter(Mandatory=$true)]
    [string]$MCBaseVersion,

    [Parameter(Mandatory=$true)]
    [string]$MCVersion,

    [Parameter(Mandatory=$true)]
    [string]$ConcertoVersion,

    [Parameter(Mandatory=$true)]
    [string]$ConcertoVersionR,

    [Parameter(Mandatory=$true)]
    [string]$LicenseServer,

    [Parameter(Mandatory=$true)]
    [string]$LicenceServerPort
)
# Install the packages required
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module Az.Storage -Force

# Give the connection string.
$ConnectionString = "DefaultEndpointsProtocol=https;AccountName=$StorageAccountName;AccountKey=$AccountKey"
$Ctx = New-AzStorageContext -ConnectionString $ConnectionString

$localTargetDirectory = "C:\Temp"


if (-not (Test-Path -Path $localTargetDirectory -PathType Container)) {
    New-Item -Path $localTargetDirectory -ItemType Directory
    Write-Host "Directory '$localTargetDirectory' created successfully."
} else {
    Write-Host "Directory '$localTargetDirectory' already exists."
}

# Download Blob to the Destination Path
# Get-AzStorageBlobContent -Blob ModelConnectInstall.cmd -Container $ContainerName -Destination $localTargetDirectory -Context $Ctx -Force
Get-AzStorageBlob -Container $ContainerName -Context $Ctx | Get-AzStorageBlobContent -Destination $localTargetDirectory -Context $Ctx -Force
Set-Location $localTargetDirectory
Start-Sleep -Seconds 60
Get-ChildItem -Recurse -Filter "*.cmd" | ForEach-Object {
    (Get-Content $_.FullName) -replace "<<JfrogToken>>", "$JfrogToken" | Set-Content $_.FullName
    (Get-Content $_.FullName) -replace "<<MCBaseVersion>>", "$MCBaseVersion" | Set-Content $_.FullName
    (Get-Content $_.FullName) -replace "<<MCVersion>>", "$MCVersion" | Set-Content $_.FullName
    (Get-Content $_.FullName) -replace "<<ConcertoVersion>>", "$ConcertoVersion" | Set-Content $_.FullName
    (Get-Content $_.FullName) -replace "<<ConcertoVersionR>>", "$ConcertoVersionR" | Set-Content $_.FullName
    (Get-Content $_.FullName) -replace "<<LicenseServer>>", "$LicenseServer" | Set-Content $_.FullName
    (Get-Content $_.FullName) -replace "<<LicenceServerPort>>", "$LicenceServerPort" | Set-Content $_.FullName
}

