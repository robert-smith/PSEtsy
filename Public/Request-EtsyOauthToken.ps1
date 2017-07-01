function Request-EtsyOauthToken {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ConsumerKey,
        [Parameter(Mandatory=$true)]
        [string]$ConsumerSecret,
        [switch]$DoNotStore
    )
}