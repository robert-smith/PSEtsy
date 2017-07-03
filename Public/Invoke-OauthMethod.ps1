<#
.SYNOPSIS
Sends a request to specified URI using OAuth. Only works with OAuth 1.0.

.DESCRIPTION
This function will send an OAuth 1.0 request to the given API. Additional parameters can be specified
when necessary. The output will be the raw response received through the Invoke-RestMethod cmdlet.

.PARAMETER ConsumerKey
The consumer key.

.PARAMETER ConsumerSecret
The consumer secret.

.PARAMETER Token
The token received through the OAuth token request process.

.PARAMETER TokenSecret
The token secret received through the OAuth token request process.

.PARAMETER Uri
The API URI.

.PARAMETER Method
The HTTP method to be used. Accepted values: DELETE, GET, POST, PUT

.PARAMETER Parameters
The name(s) of the REST method's parameter(s) and the value(s).

.EXAMPLE
$splat =
@{
    Uri = 'https://openapi.etsy.com/v2/oauth/scopes'
    Method = PUT
    ConsumerKey = 'NotARealConsumerKey'
    ConsumerSecret = 'NotReal'
    Token = 'TotallyLegitOAuthToken'
    TokenSecret = 'DefinitelyUseThis'
}

PS C:\> Invoke-OAuthMethod @splat

This will return what scopes the application has access to. This can be used to verifiy that your OAuth tokens are working.

.EXAMPLE
$splat =
@{
    Uri = 'https://openapi.etsy.com/v2/listings/0123456789'
    Method = PUT
    ConsumerKey = 'NotARealConsumerKey'
    ConsumerSecret = 'NotReal'
    Token = 'TotallyLegitOAuthToken'
    TokenSecret = 'DefinitelyUseThis'
    Parameter = @{
        title = 'Attractive Title'
        description = 'Pretty important to have one of these'
    }
}

PS C:\> Invoke-OAuthMethod @splat

This calls the updateListing method from the Etsy API and updates both the Title and Description at once.

#>
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
        [hashtable]$Parameters,
        [string]$Verifier
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
    if ($Verifier) {
        $signature += [Uri]::EscapeDataString('oauth_verifier=' + $Verifier + '&')
    }
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
    if ($Verifier) {
        $oauth_authorization += 'oauth_verifier="' + [Uri]::EscapeDataString($Verifier) + '",'
    }
    $oauth_authorization += 'oauth_version="1.0"'

    $splat.Headers = @{"Authorization" = $oauth_authorization}

    Invoke-RestMethod @splat
}#end of function
