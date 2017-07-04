Function Show-OauthWindow
{
    param(
        [System.Uri]$Url
    )

    $ie = New-Object -ComObject internetExplorer.Application
    $ie.Navigate($Url)
    $ie.Visible = $true
    
    $nativeHelperTypeDefinition =
@"
        using System;
        using System.Runtime.InteropServices;

        public static class NativeHelper
            {
            [DllImport("user32.dll")]
            [return: MarshalAs(UnmanagedType.Bool)]
            private static extern bool SetForegroundWindow(IntPtr hWnd);

            public static bool SetForeground(IntPtr windowHandle)
            {
            return NativeHelper.SetForegroundWindow(windowHandle);
            }

        }
"@
    if(-not ([System.Management.Automation.PSTypeName] "NativeHelper").Type) {
        Add-Type -TypeDefinition $nativeHelperTypeDefinition
    }

    [NativeHelper]::SetForeground($ie.HWND) > $null

    #return
    $ie
}