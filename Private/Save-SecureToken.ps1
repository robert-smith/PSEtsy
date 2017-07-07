function Save-SecureToken {
    param (
        $Token,
        [string]$Path = $EtsyTokensPath
    )
    $parent = Split-Path -Path $Path
    New-Item -Path $parent -ItemType Directory -Force > $null
    Export-Clixml -Path $Path -InputObject $Token
}