<#
.SYNOPSIS
Sends a request to specified URI using OAuth. Only works with OAuth 1.0.

.DESCRIPTION
This function will send an OAuth 1.0 request to the given API. Additional parameters can be specified
when necessary. The output will be the raw response received through the Invoke-RestMethod cmdlet.

.PARAMETER ConsumerKey
A PSCredential object containing the consumer key as the password. The username can be anything.

.PARAMETER ConsumerSecret
A PSCredential object containing the consumer secret as the password. The username can be anything.

.PARAMETER Token
A PSCredential object containing the OAuth token as the password. This is received through the OAuth token request process. The username can be anything.

.PARAMETER TokenSecret
A PSCredential object containing the OAuth token secret as the password. This is received through the OAuth token request process. The username can be anything.

.PARAMETER Uri
The base API URI.

.PARAMETER Method
The HTTP method to be used. Accepted values: DELETE, GET, POST, PUT

.PARAMETER Parameters
A hashtabled containing the name(s) of the REST method's parameter(s) and value(s).

.EXAMPLE
$splat =
@{
    Uri = 'https://openapi.etsy.com/v2/oauth/scopes'
    Method = PUT
    ConsumerKey = $ConsumerKeyCredential
    ConsumerSecret = $ConsumerKeyCredential
    Token = $TokenCredential
    TokenSecret = $TokenSecretCredential
}

PS C:\> Invoke-OAuthMethod @splat

This will return what scopes the application has access to. This can be used to verifiy that your OAuth tokens are working.

.EXAMPLE
$splat =
@{
    Uri = 'https://openapi.etsy.com/v2/listings/0123456789'
    Method = PUT
    ConsumerKey = $ConsumerKeyCredential
    ConsumerSecret = $ConsumerKeyCredential
    Token = $TokenCredential
    TokenSecret = $TokenSecretCredential
    Parameter = @{
        title = 'Attractive Title'
        description = 'Pretty important to have one of these'
    }
}

PS C:\> Invoke-OAuthMethod @splat

This calls the updateListing method from the Etsy API and updates both the Title and Description at once.

.EXAMPLE
$splat =
@{
    Uri = 'https://openapi.etsy.com/v2/listings/0123456789'
    Method = DELETE
    ConsumerKey = $ConsumerKeyCredential
    ConsumerSecret = $ConsumerKeyCredential
    Token = $TokenCredential
    TokenSecret = $TokenSecretCredential
}

PS C:\> Invoke-OAuthMethod @splat

Deletes Etsy listing 0123456789.

#>
function Invoke-OAuthMethod {
    param (
        [Parameter(Mandatory=$true)]
        [PSCredential]$ConsumerKey,
        [Parameter(Mandatory=$true)]
        [PSCredential]$ConsumerSecret,
        [PSCredential]$Token = (New-Object -TypeName PSCredential -ArgumentList 'null',(New-Object -TypeName SecureString)),
        [PSCredential]$TokenSecret = (New-Object -TypeName PSCredential -ArgumentList 'null',(New-Object -TypeName SecureString)),
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
    if ($Parameters) {
        # Clone hashtable to prevent the original from being modified
        $Parameters = $Parameters.Clone()
        $params = ConvertTo-OAuthParameter -Parameters $Parameters
        # All GET method parameters must be appended to the URI
        if ($Method -match 'GET') {
            $splat.Uri += '?' + $params.Query + '&'
        }
        # All POST and PUT method parameters must be added to the body
        elseif ($Method -match 'POST|PUT') {
            $splat.Body = $params.Body
        }
    }
    else {
        $Parameters = @{}
    }
    $Parameters.oauth_consumer_key = $ConsumerKey.GetNetworkCredential().Password
    $Parameters.oauth_nonce = $Nonce
    $Parameters.oauth_signature_method = 'HMAC-SHA1'
    $Parameters.oauth_timestamp = $Timestamp
    $Parameters.oauth_token = $Token.GetNetworkCredential().Password
    if ($Verifier) {
        $Parameters.oauth_verifier = $Verifier
    }
    $Parameters.oauth_version = '1.0'
    $params = ConvertTo-OAuthParameter -Parameters $Parameters
    $signature += $params.Signature

    # Clean up
    $Parameters.Clear()
    [gc]::Collect()

    $signature_key = [Uri]::EscapeDataString($ConsumerSecret.GetNetworkCredential().Password) + "&" + [Uri]::EscapeDataString($TokenSecret.GetNetworkCredential().Password)

    $hmacsha1 = new-object System.Security.Cryptography.HMACSHA1
    $hmacsha1.Key = [Text.Encoding]::ASCII.GetBytes($signature_key)
    $oauth_signature = [Convert]::ToBase64String($hmacsha1.ComputeHash([Text.Encoding]::ASCII.GetBytes($signature)))

    $oauth_authorization = 'OAuth '
    $oauth_authorization += 'oauth_consumer_key="' + [Uri]::EscapeDataString($ConsumerKey.GetNetworkCredential().Password) + '",'
    $oauth_authorization += 'oauth_nonce="' + [Uri]::EscapeDataString($Nonce) + '",'
    $oauth_authorization += 'oauth_signature="' + [Uri]::EscapeDataString($oauth_signature) + '",'
    $oauth_authorization += 'oauth_signature_method="HMAC-SHA1",'
    $oauth_authorization += 'oauth_timestamp="' + [Uri]::EscapeDataString($Timestamp) + '",'
    $oauth_authorization += 'oauth_token="' + [Uri]::EscapeDataString($Token.GetNetworkCredential().Password) + '",'
    if ($Verifier) {
        $oauth_authorization += 'oauth_verifier="' + [Uri]::EscapeDataString($Verifier) + '",'
    }
    $oauth_authorization += 'oauth_version="1.0"'

    $splat.Headers = @{"Authorization" = $oauth_authorization}

    Invoke-RestMethod @splat
}#end of function