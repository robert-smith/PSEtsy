<#
.SYNOPSIS
Creates a timestamp in the format needed for OAuth transactions.

.DESCRIPTION
Creates a timestamp in the format needed for OAuth transactions. The format is the total number of seconds that have elapsed
since January 1, 1970 00:00:00 GMT.

.EXAMPLE
New-Timestamp
1498678360

#>
function New-OauthTimestamp {
    $time = (Get-Date).ToUniversalTime() - (Get-Date -Date 1/1/1970).ToUniversalTime()
    [System.Convert]::ToInt64($time.TotalSeconds)
}