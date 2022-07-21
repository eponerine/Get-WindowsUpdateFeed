# Get-WindowsUpdateFeed
A PowerShell cmdlet that scrapes available Cumulative Updates from for various Windows operating systems.

## What it Does
This script parses various Microsoft-managed Atom feeds, filters on the actual Cumulative Updates, and returns a list based on parameters you may or may not want to use.

## Usage
`Get-WindowsUpdateFeed.ps1 -osVersion "Windows10"`

This will return every Cumulative Update for Windows 10 ever published across all builds (at least as much as Microsoft is revealing through Atom).

`Get-WindowsUpdateFeed.ps1 -osVersion "Windows10" -osBuild "18363"`

This will return all Cumulative Updates for Windows 10, build 18363 (at least as much as Microsoft is revealing through Atom).

`Get-WindowsUpdateFeed.ps1 -osVersion "Windows10" -osBuild "1904"`

This will return all Cumulative Updates for Windows 10, builds 19041, 19042, and 19043. The filter is doing a .Contains(), so if you leave off a digit at the end, it will find any string that matches the beginning pattern.

`Get-WindowsUpdateFeed.ps1 -osVersion "Windows10" -hoursSinceUpdatePublished 240`

This will return all Cumulative Updates for Windows 10 that have been _published_ in the last 10 days (240 hours). 
