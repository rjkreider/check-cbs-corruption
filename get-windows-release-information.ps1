$version = if ($args.Count -eq 0) { 
    "server2022" 
    write-host "`n`n"
    write-host "Using server2022 default.  You can specify a version: win10, win11, server2019, or server2022."
    write-host "`n`n"
} else { 
    $args[0] 
}

# Set the $url based on the argument
switch ($version) {
    'win10' {
        $url = "https://learn.microsoft.com/en-us/windows/release-health/release-information"
    }
    'win11' {
        $url = "https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information"
    }
    'server2019' {
        $url = "https://learn.microsoft.com/en-us/windows/release-health/windows-server-release-info"
    }
    'server2022' {
        $url = "https://learn.microsoft.com/en-us/windows/release-health/windows-server-release-info"
    }
    default {
        Write-Host "Invalid version specified. Please use win10, win11, server2019, or server2022."
        exit
    }
}

$winUpdateCatalog = "https://www.catalog.update.microsoft.com/Search.aspx?q="

$response = Invoke-WebRequest -Uri $url

# Load the response content into a variable
$htmlContent = $response.Content

# Use regex to match each <details> block
$detailsMatches = [regex]::Matches($htmlContent, '<details>(.*?)<\/details>', [System.Text.RegularExpressions.RegexOptions]::Singleline)

# Iterate through each <details> block
foreach ($detailsMatch in $detailsMatches) {
    # Extract the <summary> inner text
    $summaryMatch = [regex]::Match($detailsMatch.Groups[1].Value, '<summary>(.*?)<\/summary>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    # $innerText = if ($summaryMatch.Success) { $summaryMatch.Groups[1].Value.Trim() } else { "No summary found" }
    $innerText = if ($summaryMatch.Success) { 
        # Use regex to strip any HTML tags from the inner text
        [regex]::Replace($summaryMatch.Groups[1].Value, '<.*?>', '').Trim() 
    } else { 
        "No summary found" 
    }
    
    Write-Output "Summary: $innerText"

    # Extract table data within the <details> block (including classes and attributes)
    $tableMatches = [regex]::Matches($detailsMatch.Groups[1].Value, '<table[^>]*>(.*?)<\/table>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    
    foreach ($tableMatch in $tableMatches) {
        # Extract rows from the table
        $rowMatches = [regex]::Matches($tableMatch.Groups[1].Value, '<tr>(.*?)<\/tr>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
        
        foreach ($rowMatch in $rowMatches) {
            # Extract cells from each row (supporting <td> and <th>)
            $cellMatches = [regex]::Matches($rowMatch.Groups[1].Value, '<t[dh][^>]*>(.*?)<\/t[dh]>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
            $rowData = @($innerText)  # Initialize rowData with the summary text
            
            foreach ($cellMatch in $cellMatches) {
                # Get the cell text, stripping HTML tags
                $cellText = [regex]::Replace($cellMatch.Groups[1].Value, '<.*?>', '').Trim()  # Remove HTML tags
                if($cellText -match "^KB[0-9]") {
                $cellText += ", https://www.catalog.update.microsoft.com/Search.aspx?q=$cellText"
                }
                # Append cell text to rowData if it's not empty
                if (-not [string]::IsNullOrWhiteSpace($cellText)) {
                    $rowData += $cellText
                }
            }

            # If the rowData is not empty, output the row data
            if ($rowData.Count -gt 0) {
                $rowOutput = "$($rowData -join ', ')"
                Write-Output "$rowOutput"
                #$rowOutput | Export-Csv -path .\$innertext.csv -NoTypeInformation
            }
        }
    }
    Write-Output "`n"  # Add a new line for better readability
}
