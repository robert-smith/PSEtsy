<#
.SYNOPSIS
Retrieves all Etsy listings for the current user.

.DESCRIPTION
Outputs an array containing all of the user's Etsy listings.

.PARAMETER ConsumerKey
A PSCredential object containing the consumer key as the password. The username can be anything.

.PARAMETER ConsumerSecret
A PSCredential object containing the consumer secret as the password. The username can be anything.

.PARAMETER Token
A PSCredential object containing the OAuth token as the password. This is received through the OAuth token request process. The username can be anything.

.PARAMETER TokenSecret
A PSCredential object containing the OAuth token secret as the password. This is received through the OAuth token request process. The username can be anything.

.EXAMPLE
$splat =
@{
    ConsumerKey = $ConsumerKeyCredential
    ConsumerSecret = $ConsumerKeyCredential
    Token = $TokenCredential
    TokenSecret = $TokenSecretCredential
}

PS C:\> Get-EtsyActiveListing @splat

.OUTPUTS
PSCustomObject
#>
function Get-EtsyActiveListing {
    param (
        [PSCredential]$ConsumerKey = $EtsyTokens.consumer_key,
        [PSCredential]$ConsumerSecret = $EtsyTokens.consumer_secret,
        [PSCredential]$Token = $EtsyTokens.oauth_token,
        [PSCredential]$TokenSecret = $EtsyTokens.oauth_token_secret,
        [ValidateSet(
            'active',
            'inactive',
            'draft',
            'expired',
            'featured',
            IgnoreCase = $false
        )]
        $ListingType = 'active'
    )
    $splat = @{
        ConsumerKey = $ConsumerKey
        ConsumerSecret = $ConsumerSecret
        Token = $Token
        TokenSecret = $TokenSecret
        Uri = "https://openapi.etsy.com/v2/shops/__SELF__/listings/$ListingType"
        Method = 'GET'
        Parameters = @{
            limit = 100
            page = 1
        }
    }

    do {
        $results = Invoke-OAuthMethod @splat
        $allListings += $results.results
        $splat.Parameters.page++
    }
    while ($results.pagination.next_page)
    #return
    $allListings
}