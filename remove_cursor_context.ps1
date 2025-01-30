# Relaunch as Admin if not running as Administrator
$admin = [System.Security.Principal.WindowsPrincipal]::new([System.Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $admin.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting Administrator Privileges..."
    Start-Sleep -Seconds 2
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "✅ Running with Administrator Privileges." -ForegroundColor Green
Start-Sleep -Seconds 2

# Registry path for "Open with Cursor"
$regPath = "HKCU:\Software\Classes\Directory\Background\shell\Open with Cursor"

# Check if the key exists before deleting
if (Test-Path $regPath) {
    Write-Host "⚠️ 'Open with Cursor' is currently installed."
    Write-Host "Do you want to remove it? (Y to Remove / N to Cancel)"
    $userResponse = Read-Host
    if ($userResponse -eq "Y" -or $userResponse -eq "y") {
        Remove-Item -Path $regPath -Recurse -Force
        Write-Host "🚫 'Open with Cursor' removed from context menu."
    } else {
        Write-Host "❌ Uninstallation cancelled."
        Start-Sleep -Seconds 3
        exit
    }
} else {
    Write-Host "⚠️ 'Open with Cursor' is not installed. Nothing to remove."
}

Write-Host "Press Enter to exit."
Read-Host
