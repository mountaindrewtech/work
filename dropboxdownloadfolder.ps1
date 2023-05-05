# Set variables
$dropboxAccessToken = "ACCESS_TOKEN"
$dropboxFolderPath = "/example" # Replace with your Dropbox folder path, e.g., "/mydropboxfolder"
$localDestinationPath = "C:\example" # Replace with your local destination path, e.g., "C:\myfolder"

# Set Dropbox API URLs
$dropboxListFolderUrl = "https://api.dropboxapi.com/2/files/list_folder"
$dropboxDownloadUrl = "https://content.dropboxapi.com/2/files/download"

# Set headers
$listFolderHeaders = @{
    "Authorization" = "Bearer $dropboxAccessToken"
    "Content-Type" = "application/json"
}

$downloadHeaders = @{
    "Authorization" = "Bearer $dropboxAccessToken"
}

# Function to download a file
Function Download-FileFromDropbox ($dropboxFilePath, $localFilePath) {
    $downloadHeaders["Dropbox-API-Arg"] = (ConvertTo-Json -Compress -InputObject @{
        path = $dropboxFilePath
    })

    Try {
        Invoke-WebRequest -Uri $dropboxDownloadUrl -Headers $downloadHeaders -OutFile $localFilePath -ErrorAction Stop
        Write-Host "File downloaded successfully: $localFilePath"
    }
    Catch {
        Write-Host "Error downloading the file: $localFilePath - $($_.Exception.Message)"
    }
}

# Function to list files in a folder
Function List-DropboxFolderFiles ($path) {
    $body = (ConvertTo-Json -Compress -InputObject @{
        path = $path
        recursive = $true
    })

    Try {
        $response = Invoke-WebRequest -Uri $dropboxListFolderUrl -Headers $listFolderHeaders -Method Post -Body $body -ErrorAction Stop
        return (ConvertFrom-Json -InputObject $response.Content).entries
    }
    Catch {
        Write-Host "Error listing files in folder: $path - $($_.Exception.Message)"
        return $null
    }
}

# Download the entire folder
$dropboxFiles = List-DropboxFolderFiles -path $dropboxFolderPath
if ($dropboxFiles -ne $null) {
    foreach ($file in $dropboxFiles) {
        if ($file[".tag"] -eq "file") {
            $relativePath = $file.path_display.Substring($dropboxFolderPath.Length).Replace('/', '\')
            $localFilePath = $localDestinationPath + $relativePath
            $localFileDirectory = [System.IO.Path]::GetDirectoryName($localFilePath)
            if (-not (Test-Path -Path $localFileDirectory)) {
                New-Item -ItemType Directory -Force -Path $localFileDirectory | Out-Null
            }
            Download-FileFromDropbox -dropboxFilePath $file.path_display -localFilePath $localFilePath
        }
    }
}
