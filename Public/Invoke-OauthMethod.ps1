function Invoke-OAuthMethod {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ConsumerKey,
        [Parameter(Mandatory=$true)]
        [string]$ConsumerSecret,
        [string]$Token,
        [string]$TokenSecret,
        [Parameter(Mandatory=$true)]
        [string]$Uri,
        [ValidateSet(
            'DELETE',
            'GET',
            'POST',
            'PUT'
        )]
        [string]$Method = 'GET',
        [hashtable]$Parameters
    )

    $Nonce = New-Nonce
    $Timestamp = New-OauthTimestamp
    $splat = @{
        Uri = $Uri
        Method = $Method
    }

    $signature = "$Method&"
    $signature += [Uri]::EscapeDataString($Uri) + "&"
    $signature += [Uri]::EscapeDataString('oauth_consumer_key=' + $ConsumerKey + '&')
    $signature += [Uri]::EscapeDataString('oauth_nonce=' + $Nonce + '&')
    $signature += [Uri]::EscapeDataString('oauth_signature_method=HMAC-SHA1&')
    $signature += [Uri]::EscapeDataString('oauth_timestamp=' + $Timestamp + '&')
    $signature += [Uri]::EscapeDataString('oauth_token=' + $Token + '&')
    $signature += [Uri]::EscapeDataString('oauth_version=1.0')

    if ($Parameters) {
        $body = New-Object -TypeName System.Collections.ArrayList
        foreach ($key in $Parameters.Keys) {
            #I could only get additional parameters to work when the value was run through EscapeDataString twice
            $value = [Uri]::EscapeDataString($Parameters.$key)
            $signature += [Uri]::EscapeDataString('&' + $key + '=' + $value)
            $body.Add($key + '=' + $value)
        }

        $splat.Body = [Text.Encoding]::ASCII.GetBytes($body -join '&')
    }

    $signature_key = [Uri]::EscapeDataString($ConsumerSecret) + "&" + [Uri]::EscapeDataString($TokenSecret)

    $hmacsha1 = new-object System.Security.Cryptography.HMACSHA1
    $hmacsha1.Key = [Text.Encoding]::ASCII.GetBytes($signature_key)
    $oauth_signature = [Convert]::ToBase64String($hmacsha1.ComputeHash([Text.Encoding]::ASCII.GetBytes($signature)))

    $oauth_authorization = 'OAuth '
    $oauth_authorization += 'oauth_consumer_key="' + [Uri]::EscapeDataString($ConsumerKey) + '",'
    $oauth_authorization += 'oauth_nonce="' + [Uri]::EscapeDataString($Nonce) + '",'
    $oauth_authorization += 'oauth_signature="' + [Uri]::EscapeDataString($oauth_signature) + '",'
    $oauth_authorization += 'oauth_signature_method="HMAC-SHA1",'
    $oauth_authorization += 'oauth_timestamp="' + [Uri]::EscapeDataString($Timestamp) + '",'
    $oauth_authorization += 'oauth_token="' + [Uri]::EscapeDataString($Token) + '",'
    $oauth_authorization += 'oauth_version="1.0"'

    $splat.Headers = @{"Authorization" = $oauth_authorization}

    Invoke-RestMethod @splat
}#end of function
