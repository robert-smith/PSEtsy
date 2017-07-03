Function Show-OauthWindow
{
    param(
        [System.Uri]$Url
    )

    $ie = New-Object -ComObject internetExplorer.Application
    $ie.Navigate($Url)
    $ie.Visible = $true
    $ie
}