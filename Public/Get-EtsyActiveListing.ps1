function Get-EtsyActiveListing {
    param (
        [PSCredential]$ConsumerKey,
        [PSCredential]$ConsumerSecret,
        [PSCredential]$Token,
        [PSCredential]$TokenSecret
    )
    $splat = @{
        ConsumerKey = $ConsumerKey
        ConsumerSecret = $ConsumerSecret
        Token = $Token
        TokenSecret = $TokenSecret
        Uri = 'https://openapi.etsy.com/v2/shops/__SELF__/listings/active'
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