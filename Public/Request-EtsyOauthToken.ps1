function Request-EtsyOauthToken {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ConsumerKey,
        [Parameter(Mandatory=$true)]
        [string]$ConsumerSecret,
        [switch]$DoNotStore
    )
    $requestSplat = @{
        Uri = 'https://openapi.etsy.com/v2/oauth/request_token'
        ConsumerKey = $ConsumerKey
        ConsumerSecret = $ConsumerSecret
        Method = 'POST'
    }
    $confirmUrl = Invoke-OAuthMethod @requestSplat
    $decodedUrl = [Web.HttpUtility]::UrlDecode($confirmUrl.Substring(10))
    $tempTokens = Get-TempToken -Response $decodedUrl
    $window = Show-OauthWindow -Url $decodedUrl
    # Wait until page is loaded before looking for the element
    Start-Sleep -Seconds 1
    $waitSplat = @{
        IEObject = $window
        TagName = 'DIV'
        Attributes = @{
            ClassName = 'oauth-verifier'
        }
    }
    $oauthVerifier = Wait-ForElement @waitSplat
    $window.Quit()
    $tokensSplat = @{
        Uri = 'https://openapi.etsy.com/v2/oauth/access_token'
        ConsumerKey = $ConsumerKey
        ConsumerSecret = $ConsumerSecret
        Token = $tempTokens.oauth_token
        TokenSecret = $tempTokens.oauth_token_secret
        Method = 'POST'
        Verifier = $oauthVerifier.textContent
    }
    $tokens = (Invoke-OAuthMethod @tokensSplat).Split('&')
    $obj = New-Object -TypeName PSCustomObject
    foreach ($token in $tokens) {
        $pieces = $token.Split('=')
        $obj | Add-Member -MemberType NoteProperty -Name $pieces[0] -Value $pieces[1]
    }
    #return
    $obj
}