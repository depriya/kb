param (
    [Parameter(Mandatory=$true)]
    [string]$StorageAccountName,

    [Parameter(Mandatory=$true)]
    [string]$ContainerName,

    [Parameter(Mandatory=$true)]
    [string]$AccountKey,

    [Parameter(Mandatory=$true)]
    [string]$localFolderPath
)


Write-Host "Upload Script execution started"

Write-Host "Upload Script - Installing modules"
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module Az.Storage -Force
Write-Host "Upload Script - Installing modules completed"

$ConnectionString = "DefaultEndpointsProtocol=https;AccountName=$StorageAccountName;AccountKey=$AccountKey"
$Ctx = New-AzStorageContext -ConnectionString $ConnectionString


Write-Host "Upload Script - Uploading files and folders under $localFolderPath to the storage container."
$filesToUpload = Get-ChildItem -Path $localFolderPath -File -Recurse
$lastDirectory = (Split-Path $localFolderPath -Leaf)

foreach ($file in $filesToUpload) {
    $relativePath = $file.FullName.Substring($localFolderPath.Length + 1)
    $blobPath = Join-Path -Path $lastDirectory -ChildPath $relativePath.Replace('\', '/')
    Write-Host "Uploading $($file.FullName) to $blobPath"
    Set-AzStorageBlobContent -Container $ContainerName -Blob $blobPath -File $file.FullName -Context $Ctx -Force
    Write-Host "Uploaded $($file.FullName) to $blobPath completed."
}

Write-Host "Upload Script - All files and folders under $localFolderPath have been uploaded to the storage container $($ContainerName)."