# Inputs
$localFilePath = "C:\Users\Public\Desktop\test\test.txt"
$dropboxFilePath = "/example.txt"
$dropboxAccessToken = "API_ACCESS_TOKEN"
$isZip = $False
$runAfter = $False

# Set Dropbox API URL
$dropboxApiUrl = "https://content.dropboxapi.com/2/files/download"

# Set headers
$headers = @{
    "Authorization" = "Bearer $dropboxAccessToken"
    "Content-Type" = "application/octet-stream"
    "Dropbox-API-Arg" = (ConvertTo-Json -Compress -InputObject @{
        path = $dropboxFilePath
    })
}

# Download the file
Try {
    Invoke-WebRequest -Uri $dropboxApiUrl -Headers $headers -OutFile $localFilePath -ErrorAction Stop
    Write-Host "File downloaded successfully to $localFilePath"
}
Catch {
    Write-Host "Error downloading the file: $($_.Exception.Message)"
}

if ($isZip) {
    $localFilePathUnzipped = $localFilePath.TrimEnd(".zip")
    Expand-Archive -Path $localFilePath -DestinationPath $localFilePathUnzipped -Force
    Remove-Item -Path $localFilePath -Force
}

if ($runAfter) {
    & $localFilePath
}

