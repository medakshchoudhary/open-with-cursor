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

# Check if "Open with Cursor" already exists
if (Test-Path $regPath) {
    Write-Host "⚠️ 'Open with Cursor' is already in the context menu."
    Write-Host "Do you want to delete it and reinstall? (Y to Delete / N to Cancel)"
    $userResponse = Read-Host
    if ($userResponse -ne "Y" -and $userResponse -ne "y") {
        Write-Host "❌ Installation cancelled."
        Start-Sleep -Seconds 3
        exit
    }
    # If user wants to delete, remove the existing entry
    Remove-Item -Path $regPath -Recurse -Force
    Write-Host "🚫 'Open with Cursor' removed from context menu."
    Start-Sleep -Seconds 2
} else {
    Write-Host "No existing 'Open with Cursor' found."
}

# Ask user for automatic or manual cursor location detection
Write-Host "Would you like to try automatic detection (A) or provide the path manually (M)? (A/M)"
$userResponse = Read-Host

$cursorPath = $null
if ($userResponse -eq "A" -or $userResponse -eq "a") {
    Write-Host "✅ Attempting automatic detection..."
    Start-Sleep -Seconds 1

    # Try to find Cursor automatically
    $defaultPaths = @(
        "$env:LOCALAPPDATA\Programs\Cursor\Cursor.exe",
        "$env:PROGRAMFILES\Cursor\Cursor.exe",
        "$env:PROGRAMFILES(x86)\Cursor\Cursor.exe"
    )

    foreach ($path in $defaultPaths) {
        if (Test-Path $path) {
            $cursorPath = $path
            break
        }
    }

    if (-not $cursorPath) {
        Write-Host "❌ Cursor.exe not found automatically."
        Start-Sleep -Seconds 2
    }
}

# If automatic detection failed, ask user to provide the path manually
if (-not $cursorPath) {
    Write-Host "Would you like to manually provide the location of Cursor.exe? (Y/N)"
    $userResponse = Read-Host
    if ($userResponse -eq "Y" -or $userResponse -eq "y") {
        Write-Host "Please provide the full path to Cursor.exe (include quotes if necessary):"
        $cursorPath = Read-Host
        if (-not (Test-Path $cursorPath)) {
            Write-Host "❌ The provided path is invalid. Exiting installation."
            Start-Sleep -Seconds 3
            exit
        }
    } else {
        Write-Host "❌ Installation cancelled."
        Start-Sleep -Seconds 3
        exit
    }
}

Write-Host "✅ Using Cursor Path: $cursorPath" -ForegroundColor Green
Start-Sleep -Seconds 2

# Registry path for command execution
$commandPath = "$regPath\command"

# Create Registry Key for "Open with Cursor"
New-Item -Path $regPath -Force | Out-Null
Set-ItemProperty -Path $regPath -Name "(Default)" -Value "Open with Cursor"
Set-ItemProperty -Path $regPath -Name "Icon" -Value "$cursorPath,0"

# Create Command Key to execute Cursor
New-Item -Path $commandPath -Force | Out-Null
Set-ItemProperty -Path $commandPath -Name "(Default)" -Value "`"$cursorPath`" `"%V`""

Write-Host "✅ 'Open with Cursor' successfully added to context menu!" -ForegroundColor Cyan
Start-Sleep -Seconds 2

Write-Host "Press Enter to exit."
Read-Host
