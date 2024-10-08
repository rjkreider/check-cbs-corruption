if ($args.Count -gt 0) {
    $logFilePath = $args[0]  # Use the first argument as the log file path
if (Test-Path $logFilePath) {
    try {
        # Try to open the file for reading
        $stream = [System.IO.File]::OpenRead($logFilePath)
        $stream.Close() # Close the stream if successful
    } catch {
        Write-Host "$logFilePath exists but unable to read."
return
    }
} else {
    Write-Host "$logFilePath does not exist."
return
}} else {
    $logFilePath = 'C:\Windows\logs\cbs\Cbs.log'  # Default log file path
}
# Initialize a hash table to store unique last column entries
$uniqueLastColumns = @{}

$randomString = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 5 | ForEach-Object {[char]$_})

# Extract lines containing "CSI Payload Corrupt" and process each unique last column
Select-String -Path $logFilePath -Pattern "CSI Payload Corrupt" | ForEach-Object {
    # Split the line by tab or spaces, then get the last part (last column)
    $columns = $_.Line -split '\s+'
    $lastColumn = $columns[-1].Trim()

    # Check if the lastColumn is unique and add to the hash table
    if (-not $uniqueLastColumns.ContainsKey($lastColumn)) {
        $uniqueLastColumns[$lastColumn] = $null  # Add unique lastColumn to the hash table
    }
}

# Process each unique last column value
if($uniqueLastColumns.Keys.Count -lt 2) {
write-host "No corruption identified in $logFilePath"
return
}

foreach ($lastColumn in $uniqueLastColumns.Keys) {
    # Apply the regex match
    if ($lastColumn -match '^(.*?)(_\w{16}_)([0-9]+).([0-9]).([0-9]+).([0-9]+)_(\w+)_(\w{16})(.*)$') {
    # Extract the matched groups
    $package = $matches[1]
    $hash1 = $matches[2] -replace '_', ''  # Remove the underscores
    $version = $matches[3]
    $versionMinor = $matches[4]  # Variable length build
    $build = $matches[5]
    $ubr = $matches[6]     # Variable length UBR
    $etc = $matches[7]
    $hash2 = $matches[8]
    $fullpath = $matches[9]
    $filename = $fullPath -replace '.*[\\\/]', ''
    $extractPath = $lastColumn -split '\\' | Select-Object -First 1

    # Output the extracted information
    Write-Host $lastColumn
    Write-Host "Package:  $package"
    Write-Host "Version:  $version"
    Write-Host "Minor:    $versionminor"
    Write-Host "Build:    $build"
    Write-Host "UBR:      $ubr"
    Write-Host "Etc:      $etc"
    Write-Host "Hash2:    $hash2"
    Write-Host "Filename: $filename"
    Write-Host "----------------------------------"


add-content -path fix-$randomString.txt -value "$extractPath"

} else {
    # Write-Host "No match for: $lastColumn"
}

}

write-host "Fix file: fix-$randomString.txt"