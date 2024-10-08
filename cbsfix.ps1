# Validate input arguments
if ($args.Count -lt 3) {
    Write-Output "Usage: cbsfix.ps1 <fix.txt> <source folder> <destination folder>"
    return
}

# Define the paths from input arguments
$filePath = $args[0]
$sourceFolder = $args[1]
$destinationFolder = $args[2]

# Check if the source and destination directories exist
if (-not (Test-Path $sourceFolder)) {
    Write-Error "Source folder is invalid: $sourceFolder"
    return
}

# Create the destination directory if it does not exist
if (-not (Test-Path $destinationFolder)) {
    try {
        New-Item -Path $destinationFolder -ItemType Directory -ErrorAction Stop
        Write-Output "Created destination folder: $destinationFolder"
    } catch {
        Write-Error "Failed to create destination folder: $destinationFolder. Error: $_"
        return
    }
}

# Check if the file with the list of paths exists
if (-not (Test-Path $filePath)) {
    Write-Error "File not found: $filePath"
    return
}

# Read the file line by line and process each file path
try {
    Get-Content -Path $filePath | ForEach-Object {
        # Trim any whitespace from the line
        $relativePath = $_.Trim()
        
        # Build the full source path
        $sourcePath = Join-Path -Path $sourceFolder -ChildPath $relativePath

        # Check if the source file exists
        if (Test-Path $sourcePath) {
            try {
                # Copy the file or directory to the destination folder
                Copy-Item -Path $sourcePath -Destination $destinationFolder -Recurse -Force -ErrorAction Stop
                Write-Output "Copied: $sourcePath to $destinationFolder"
            } catch {
                Write-Error "Failed to copy: $sourcePath. Error: $_"
            }
        } else {
            Write-Error "Source path does not exist: $sourcePath"
        }
    }
} catch {
    Write-Error "Failed to read or process file: $filePath. Error: $_"
}
