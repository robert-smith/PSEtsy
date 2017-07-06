function Request-EtsyOauthToken {
    param (
        [Parameter(Mandatory=$true)]
        [PSCredential]$ConsumerKey,
        [Parameter(Mandatory=$true)]
        [PSCredential]$ConsumerSecret,
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
    $waitSplat = @{
        IEObject = $window
        TagName = 'DIV'
        Attributes = @{
            ClassName = 'oauth-verifier'
        }
    }
    # Wait until page is loaded before looking for the element
    Start-Sleep -Seconds 1
    $oauthVerifier = Wait-ForElement @waitSplat
    if ($window.HWND) {
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
        $tokenObj = New-Object -TypeName PSCustomObject
        foreach ($token in $tokens) {
            $pieces = $token.Split('=')
            $secure = ConvertTo-SecureString -String $pieces[1] -AsPlainText -Force
            $creds = New-Object -TypeName PSCredential -ArgumentList $pieces[0],$secure
            $tokenObj | Add-Member -MemberType NoteProperty -Name $pieces[0] -Value $creds
        }
        #Cleanup tokens from memory
        $tokens = $null
        [gc]::Collect()
        
        $tokenObj | Add-Member -MemberType NoteProperty -Name consumer_key -Value $ConsumerKey
        $tokenObj | Add-Member -MemberType NoteProperty -Name consumer_secret -Value $ConsumerSecret

        if ($DoNotStore -eq $true) {
            #return
            $tokenObj
        }
        else {
            Save-SecureToken -Token $tokenObj
        }
    }
}