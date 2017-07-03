function Get-TempToken {
    param (
        [string]$Response
    )
    $array = New-Object -TypeName System.Collections.ArrayList
    $parameters = ($Response -split '\?')[1] -split '&'
    foreach ($parameter in $parameters) {
        $item = $parameter -split '='
        $array.Add(
            @{
                "$($item[0])" = "$($item[1])"
            }
        ) | Out-Null
    }
    
    $oauthToken = $array.Where({$_.Keys -eq 'oauth_token'}) | Select-Object -Unique
    $oauthTokenSecret = $array.Where({$_.Keys -eq 'oauth_token_secret'}) | Select-Object -Unique
    #return
    [PSCustomObject]@{
        oauth_token = $oauthToken.Values
        oauth_token_secret = $oauthTokenSecret.Values
    }
}