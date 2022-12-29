function ConvertTo-EncodedFilePath {
    Param(
        [Parameter(Mandatory=$True)][String]$FilePath
    )

    $FilePath = $FilePath.Replace('%', '%25')
    $FilePath = $FilePath.Replace(':', '%3A')
    $FilePath = $FilePath.Replace('/', '%2F')
    $FilePath = $FilePath.Replace('?', '%3F')
    $FilePath = $FilePath.Replace('#', '%23')
    $FilePath = $FilePath.Replace('[', '%5B')
    $FilePath = $FilePath.Replace(']', '%5D')
    $FilePath = $FilePath.Replace('@', '%40')
    $FilePath = $FilePath.Replace('!', '%21')
    $FilePath = $FilePath.Replace('&', '%26')
    $FilePath = $FilePath.Replace("'", '%27')
    $FilePath = $FilePath.Replace('(', '%28')
    $FilePath = $FilePath.Replace(')', '%29')
    $FilePath = $FilePath.Replace('*', '%2A')
    $FilePath = $FilePath.Replace('+', '%2B')
    $FilePath = $FilePath.Replace(',', '%2C')
    $FilePath = $FilePath.Replace(';', '%3B')
    $FilePath = $FilePath.Replace('=', '%3D')
    $FilePath = $FilePath.Replace('{', '%7B')
    $FilePath = $FilePath.Replace('}', '%7D')
    $FilePath = $FilePath.Replace('<', '%3C')
    $FilePath = $FilePath.Replace('>', '%3E')
    $FilePath = $FilePath.Replace('~', '%7E')
    $FilePath = $FilePath.Replace('é', '%C3%A9')

    $FilePath = $FilePath -Replace '^(\\\\.\\)?.\%3A', $DrivePath
    $FilePath = $FilePath.Replace('\.', '\%2E')

    # Directory / filename / extension specific processing.
    $FilePathDirectory = [System.IO.Path]::GetDirectoryName($FilePath)
    $FilePathFilename = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
    $FilePathExtension = [System.IO.Path]::GetExtension($FilePath)
    $FilePathExtension = $FilePathExtension.Replace('.db', '.db_')

    return [System.IO.Path]::Join($FilePathDirectory, $FilePathFilename + $FilePathExtension)
}

function Set-VelociraptorKapeTargetsOriginalTimestamps {
    Param(
        [Parameter(Mandatory=$True)][String]$DrivePath,
        [Parameter(Mandatory=$True)][String]$KapeFilesMetadataFile
    )

    Write-Host "[INFO] Starting to process '$DrivePath' folder..."
    Write-Host "[INFO] Will use metadata from '$KapeFilesMetadataFile'"

    $Counter = 0
    foreach($line in Get-Content $KapeFilesMetadataFile) {
        $FileMetadata = $line | ConvertFrom-Json

        # Replace drive letter from metadata file path with the specified collected files DrivePath.
        $FilePath = $FileMetadata.SourceFile -Replace '^(\\\\.\\)?.:', $DrivePath

        # Some chars may be percent-encoded (but not following URL encoding specification).
        If (!(Test-Path -Path $FilePath)) {
            $FilePath = ConvertTo-EncodedFilePath -FilePath $FileMetadata.SourceFile
        }

        If (Test-Path -Path $FilePath) {
            try {
                $FileItem = Get-Item "$FilePath"
                $FileItem.CreationTime=($FileMetadata.Created)
                $FileItem.LastWriteTime=($FileMetadata.Modified)
                $FileItem.LastAccessTime=($FileMetadata.LastAccessed)
                $Counter = $Counter + 1
            }
            catch {
                Write-Host -ForegroundColor Red "[ERROR] '$FilePath' couldn't be processed"
            }
        }
        Else {
            Write-Host -ForegroundColor Yellow "[WARN] '$FilePath' not found"
        }
    }

    Write-Host "[INFO] Processed $Counter files!"

}

Set-VelociraptorKapeTargetsOriginalTimestamps -DrivePath 'D:\Artemis\1-Sources\2-Endpoints\A1-SRV-P-IIS15\Velociraptor\uploads\C_drive' -KapeFilesMetadataFile 'D:\Artemis\1-Sources\2-Endpoints\A1-SRV-P-IIS15\Velociraptor\results\Windows.KapeFiles.Targets%2FAll File Metadata.json'