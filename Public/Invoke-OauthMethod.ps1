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
            'PATCH',
            'POST',
            'PUT'
        )]
        [string]$Method = 'GET'
    )

    $Nonce = New-Nonce
    $Timestamp = New-OauthTimestamp

    $signature = "$Method&"
    $signature += [Uri]::EscapeDataString($Uri) + "&"
    $signature += [Uri]::EscapeDataString("oauth_consumer_key=" + $ConsumerKey + "&")
    $signature += [Uri]::EscapeDataString("oauth_nonce=" + $Nonce + "&")
    $signature += [Uri]::EscapeDataString("oauth_signature_method=HMAC-SHA1&")
    $signature += [Uri]::EscapeDataString("oauth_timestamp=" + $Timestamp + "&")
    $signature += [Uri]::EscapeDataString("oauth_token=" + $Token + "&")
    $signature += [Uri]::EscapeDataString("oauth_version=1.0")

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

    Invoke-RestMethod -Uri $Uri -Headers @{"Authorization" = $oauth_authorization} -Method $Method
}#end of function