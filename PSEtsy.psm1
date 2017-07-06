$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Exclude *.tests.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Exclude *.tests.ps1 -ErrorAction SilentlyContinue )
$EtsyTokensPath = "$home\.etsy\api_tokens"
$EtsyTokens = Import-Clixml -Path $EtsyTokensPath

Foreach($import in @($Public + $Private))
{
    Try
    {
        Import-Module $import.fullname -Force
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

Export-ModuleMember -Function $Public.BaseName -Variable EtsyTokens, EtsyTokensPath