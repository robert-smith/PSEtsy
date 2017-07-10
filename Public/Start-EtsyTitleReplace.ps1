<#
.SYNOPSIS
Replaces text in the title of all listings in a specified state.

.DESCRIPTION
If the TextToReplace is found in a title, it will be replaced with the ReplaceWith string. If the text it not found, that title will be left unmodified.
WARNING: Running this against inactive or draft listings will cause them to become activated. This can cause the shop to be charged listing fees.

.PARAMETER TextToReplace
The text that will be searched in all titles.

.PARAMETER ReplaceWith
The string that will be replace TextToReplace if it is found in the listing title.

.PARAMETER ListingType
One of active, inactive, or draft.

.EXAMPLE
Start-EtsyTitleReplace -TextToReplace "comes in 2 colors" -ReplaceWith "comes in 3 colors" -ListingType active

.NOTES
General notes
#>
function Start-EtsyTitleReplace {
    param (
        [Parameter(Mandatory=$true)]
        [string]$TextToReplace,
        [Parameter(Mandatory=$true)]
        [string]$ReplaceWith,
        [ValidateSet(
            'active',
            'inactive',
            'draft',
            IgnoreCase = $false
        )]
        [Parameter(Mandatory=$true)]
        [string]$ListingType
    )
    BEGIN {
        Import-Module PSEtsy -Force
        $activity = 'Updating Listing Titles'
        Write-Progress -Activity $activity -CurrentOperation "Getting $ListingType listings..."
        $listings = Get-EtsyListing -ListingType $ListingType
        $i = 1
    }
    PROCESS {
        foreach ($listing in $listings) {
            Write-Progress -Activity $activity -CurrentOperation "Title: $($listing.title)" -PercentComplete (($i/$listings.Count)*100)
            $return = @{
                OldTitle = $listing.title
            }
            $newTitle = $listing.title.Replace($TextToReplace,$ReplaceWith)
            if ($newTitle -ne $listing.title) {
                #$change = Set-EtsyListing -ListingID $listing.listing_id -Title $newTitle
                #$return.NewTitle = $change.results.title
                $return.NewTitle = $newTitle
            }
            else {
                $return.NewTitle = "Skipped - `"$TextToReplace`" not found in title"
            }
            $i++
            #return in different propery order
            [PSCustomObject]$return | Select-Object -Property OldTitle, NewTitle
        }

    }
}