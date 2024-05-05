param (
    [Parameter(Mandatory = $true)]
    [string]$FileName
)

Start-Process -FilePath "$($FileName)" -Wait -NoNewWindow