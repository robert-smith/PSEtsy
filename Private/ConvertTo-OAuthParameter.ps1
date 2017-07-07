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
        # I could only get additional parameters to work when the value was run through EscapeDataString twice
        $value = [Uri]::EscapeDataString($Parameters.$key)
        # Escape characters not covered by EscapeDataString
        $value = $value.Replace('!','%21')
        $value = $value.Replace('*','%2A')
        $value = $value.Replace('(','%28')
        $value = $value.Replace(')','%29')
        $value = $value.Replace("'",'%27')
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