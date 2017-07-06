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
        ) > $null
    }
    
    $oauthToken = $array.Where({$_.Keys -eq 'oauth_token'}) |
        Select-Object -ExpandProperty Values -Unique |
        ConvertTo-SecureString -AsPlainText -Force
    $oauthTokenSecret = $array.Where({$_.Keys -eq 'oauth_token_secret'}) |
        Select-Object -ExpandProperty Values -Unique |
        ConvertTo-SecureString -AsPlainText -Force
    #return
    [PSCustomObject]@{
        oauth_token = New-Object -TypeName PSCredential -ArgumentList 'oauth_token', $oauthToken
        oauth_token_secret = New-Object -TypeName PSCredential -ArgumentList 'oauth_token', $oauthTokenSecret
    }
}