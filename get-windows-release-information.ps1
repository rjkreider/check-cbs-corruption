# Default to server2022 if no argument is passed
$version = if ($args.Count -eq 0) { "server2022" } else { 
    $args[0].ToLower()  # Normalize input to lowercase for consistency
}

# Set the $url based on the argument
$url = switch ($version) {
    'win10'       { "https://learn.microsoft.com/en-us/windows/release-health/release-information" }
    'win11'       { "https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information" }
    'server2019'  { "https://learn.microsoft.com/en-us/windows/release-health/windows-server-release-info" }
    'server2022'  { "https://learn.microsoft.com/en-us/windows/release-health/windows-server-release-info" }
    default       { "https://learn.microsoft.com/en-us/windows/release-health/windows-server-release-info" }
}

$winUpdateCatalog = "https://www.catalog.update.microsoft.com/Search.aspx?q="

# Safely handle web requests
try {
    $response = Invoke-WebRequest -Uri $url -ErrorAction Stop
} catch {
    Write-Error "Failed to retrieve the URL content. Please check your connection or the URL."
    return
}

# Load the response content into a variable
$htmlContent = $response.Content

# Use regex to match each <details> block
$detailsMatches = [regex]::Matches($htmlContent, '<details>(.*?)<\/details>', [System.Text.RegularExpressions.RegexOptions]::Singleline)

# Process each <details> block
foreach ($detailsMatch in $detailsMatches) {
    # Extract the <summary> inner text
    $summaryMatch = [regex]::Match($detailsMatch.Groups[1].Value, '<summary>(.*?)<\/summary>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    
    $innerText = if ($summaryMatch.Success) { 
        # Strip HTML tags from the summary
        [regex]::Replace($summaryMatch.Groups[1].Value, '<.*?>', '').Trim() 
    } else { 
        "No summary found" 
    }

    Write-Output "Summary: $innerText"

    # Extract table data within the <details> block
    $tableMatches = [regex]::Matches($detailsMatch.Groups[1].Value, '<table[^>]*>(.*?)<\/table>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    
    foreach ($tableMatch in $tableMatches) {
        # Extract rows from the table
        $rowMatches = [regex]::Matches($tableMatch.Groups[1].Value, '<tr>(.*?)<\/tr>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
        
        foreach ($rowMatch in $rowMatches) {
            # Extract cells from each row (supporting <td> and <th> elements)
            $cellMatches = [regex]::Matches($rowMatch.Groups[1].Value, '<t[dh][^>]*>(.*?)<\/t[dh]>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
            $rowData = @($innerText)  # Initialize rowData with the summary text
            
            foreach ($cellMatch in $cellMatches) {
                # Get the cell text and strip HTML tags
                $cellText = [regex]::Replace($cellMatch.Groups[1].Value, '<.*?>', '').Trim()

                # Add a link to the update catalog for KB references
                if ($cellText -match "^KB[0-9]+") {
                    $cellText += ", $winUpdateCatalog$cellText"
                }

                # Append non-empty cell text to rowData
                if (-not [string]::IsNullOrWhiteSpace($cellText)) {
                    $rowData += $cellText
                }
            }

            # Output non-empty row data
            if ($rowData.Count -gt 1) {
                $rowOutput = $rowData -join ', '
                Write-Output $rowOutput
                # Optionally export row data to CSV (uncomment if needed)
                # $rowOutput | Export-Csv -Path ".\$innerText.csv" -NoTypeInformation
            }
        }
    }
    Write-Output "`n"  # Add a new line for better readability
}
