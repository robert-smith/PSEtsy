function ConvertTo-OAuthParameter {
    param (
        [hashtable]$Parameters
    )
    $body = New-Object -TypeName System.Collections.ArrayList
    $signature = New-Object -TypeName System.Collections.ArrayList
    $amp = [Uri]::EscapeDataString('&')
    #Parameters must be sorted
    $Keys = $Parameters.GetEnumerator() | Sort-Object -Property Name
    foreach ($key in $Keys.Name) {
        #I could only get additional parameters to work when the value was run through EscapeDataString twice
        $value = [Uri]::EscapeDataString($Parameters.$key)
        $signature.Add([Uri]::EscapeDataString($key + '=' + $value)) > $null
        $body.Add($key + '=' + $value) > $null
    }
    #return
    [PSCustomObject]@{
        Signature = $signature -join $amp
        Body = [Text.Encoding]::ASCII.GetBytes($body -join '&')
        Query = $body -join '&'
    }
}