# Set variables
$dropboxAccessToken = "ACCESS_TOKEN"
$localFolderPath = "C:\example" # Replace with your local folder path, e.g., "C:\myfolder"
$dropboxDestinationPath = "/test" # Replace with your desired destination path in Dropbox, e.g., "/mydropboxfolder"

# Set Dropbox API URL
$dropboxApiUrl = "https://content.dropboxapi.com/2/files/upload"

# Set headers
$headers = @{
    "Authorization" = "Bearer $dropboxAccessToken"
    "Content-Type" = "application/octet-stream"
}

# Function to upload a file
Function Upload-FileToDropbox ($localFilePath, $dropboxFilePath) {
    $headers["Dropbox-API-Arg"] = (ConvertTo-Json -Compress -InputObject @{
        path = $dropboxFilePath
        mode = "add"
        autorename = $true
        mute = $false
    })

    Try {
        $fileContent = [System.IO.File]::ReadAllBytes($localFilePath)
        Invoke-WebRequest -Uri $dropboxApiUrl -Headers $headers -Method Post -Body $fileContent -ErrorAction Stop
        Write-Host "File uploaded successfully: $dropboxFilePath"
    }
    Catch {
        Write-Host "Error uploading the file: $dropboxFilePath - $($_.Exception.Message)"
    }
}

# Upload the entire folder
Get-ChildItem -Path $localFolderPath -Recurse | ForEach-Object {
    if (-not $_.PSIsContainer) {
        $relativePath = $_.FullName.Substring($localFolderPath.Length).Replace('\', '/')
        $dropboxFilePath = $dropboxDestinationPath + $relativePath
        Upload-FileToDropbox -localFilePath $_.FullName -dropboxFilePath $dropboxFilePath
    }
}
