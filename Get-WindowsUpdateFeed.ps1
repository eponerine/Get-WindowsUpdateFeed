param (
    [Parameter(Mandatory)]
    [ValidateSet('Windows10','Windows11','Server2016','Server2019','Server2022')]
    [string]$osVersion,
    [string]$osBuild,
    [int]$hoursSinceUpdatePublished = 9999999
)

 <#
    .SYNOPSIS
    A PowerShell cmdlet that scrapes available Cumulative Updates for various Windows operating systems.

    .DESCRIPTION
    Quickly query Microsoft's Atom feed for specified Windows OS updates and filter in-line!

    .PARAMETER osVersion
    Specifies the version of Windows you are searching for.

    .PARAMETER osBuild
    Specifies the build number of the Windows OS you are searching for. You can submit an "incomplete" build 
    number to find multiple Cumulative Updates for various builds (ex - "1904" will return Windows 10 builds 19042, 19043, and 19044)

    .PARAMETER hoursSinceUpdatePublished
    Specifies the number of hours from today's date to filter on the found Cumulative Updates.

    .INPUTS
    None. You cannot pipe objects to Get-WindowsUpdateFeed.

    .OUTPUTS
    Collections.Generic.List

    .EXAMPLE
    PS> Get-WindowsUpdateFeed.ps1 -osVersion "Windows10"

    .EXAMPLE
    PS> Get-WindowsUpdateFeed.ps1 -osVersion "Windows10" -osBuild "19043"

    .EXAMPLE
    PS> Get-WindowsUpdateFeed.ps1 -osVersion "Windows10" -hoursSinceUpdatePublished 240

    .LINK
    https://github.com/eponerine/Get-WindowsUpdateFeed

#>

# Determine the appropriate URL to use based on osVersion passed from parameter
# These were found at https://support.microsoft.com/en-us/rss-feed-picker
switch ($osVersion) {
    
    'Windows10' { $feedURL = "https://support.microsoft.com/en-us/feed/atom/6ae59d69-36fc-8e4d-23dd-631d98bf74a9" }
    'Windows11' { $feedURL = "https://support.microsoft.com/en-us/feed/atom/4ec863cc-2ecd-e187-6cb3-b50c6545db92" }
    'Server2016' { $feedURL = "https://support.microsoft.com/en-us/feed/atom/c3a1be8a-50db-47b7-d5eb-259debc3abcc" }
    'Server2019' { $feedURL = "https://support.microsoft.com/en-us/feed/atom/eb958e25-cff9-2d06-53ca-f656481bb31f" }
    'Server2022' { $feedURL = "https://support.microsoft.com/en-us/feed/atom/2d67e9fb-2bd2-6742-08ee-628da707657f" }
}

# Get Atom Feed
# (this should probably be in a try/catch)
$response = Invoke-WebRequest -Uri $feedURL -UseBasicParsing -ContentType "application/xml"

# If error, log it and exit
If ($response.StatusCode -ne "200") {
    Write-Error "Message: $($response.StatusCode) $($response.StatusDescription)"
    Exit
}

# Cast the returned payload as an XML document (we need to ignore the first character because of some weird encoding thing; dunno why but a ? character appears)
# Create an empty list to add the content to
$feedXml = [xml]$response.Content.Substring(1)
$feedEntries = New-Object Collections.Generic.List[PSCustomObject]

# Get the datetime at current execution start so we don't have to compute it each loop iteration
$now = Get-Date

# Loop thru each entry and check if the entry has been Published within X hours
ForEach ($e in $feedXml.feed.entry) {

    If (( ($now - [datetime]$e.Published).TotalHours -le $hoursSinceUpdatePublished) -and ($e.title.'#text'.Contains('OS Build')) -and ($e.title.'#text'.Contains($osBuild)) ) {

        $tempObject = [PSCustomObject] @{
            'Published' = [datetime]$e.published
            'Updated'   = [datetime]$e.updated
            'Title'     = $e.title.'#text'
            'Link'      = $e.link.href
        }

        # Add to our list to notify about
        $feedEntries.Add($tempObject)
    }
}

return ($feedEntries | Sort-Object -Property Published -Descending)