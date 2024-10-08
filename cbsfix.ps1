if ($args.Count -lt 3) {
write-host "cbsfix.ps1 <fix.txt> <source> <destination>"
return
 }
# Define the path to the file containing the list of strings
$filePath = $args[0]

# Define the destination folder where you want to copy the files
$destinationFolder = $args[2]

$sourceFolder = $args[1]

# Create the backup directory if it doesn't exist
if (-not (Test-Path $destinationFolder)) {
    New-Item -Path $destinationFolder -ItemType Directory
}

if (-not (test-path $sourceFolder)) {
write-host "source folder invalid"
return
}

# Read the file line by line

Get-Content -Path $filePath | ForEach-Object {
    # Trim any whitespace from the line
    $sourcePath = $_.Trim()
$sourcePath = "$sourceFolder\$sourcePath"

    # Check if the source path exists
    if (Test-Path $sourcePath) {
        # Copy the item to the destination folder
        Copy-Item -Path $sourcePath -Destination $destinationFolder -Recurse -Force
        Write-Host "Copied: $sourcePath to $destinationFolder"
    } else {
        Write-Host "Path does not exist: $sourcePath"
    }
}
