# Noor (نور) - Uninstaller (Windows)
# ============================================================
# Usage: .\uninstall.ps1
# ============================================================

$ErrorActionPreference = "Stop"

$NOOR_INSTALL_DIR = "$env:USERPROFILE\.local\share\noor"
$NOOR_BIN_DIR = "$env:USERPROFILE\.local\bin"

function Write-Status($msg) {
    Write-Host "[Noor] $msg" -ForegroundColor Cyan
}

function Write-Success($msg) {
    Write-Host "[✓] $msg" -ForegroundColor Green
}

function Write-Warning($msg) {
    Write-Host "[!] $msg" -ForegroundColor Yellow
}

function Write-Info($msg) {
    Write-Host "[i] $msg" -ForegroundColor DarkCyan
}

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║                                                              ║" -ForegroundColor Yellow
Write-Host "║         🗑️  Noor (نور) - Uninstaller                        ║" -ForegroundColor Yellow
Write-Host "║                                                              ║" -ForegroundColor Yellow
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host ""

Write-Status "This will remove Noor from your system."
$confirm = Read-Host "Are you sure? (y/N)"

if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Status "Uninstall cancelled."
    exit 0
}

# Remove installation directory
if (Test-Path $NOOR_INSTALL_DIR) {
    Write-Status "Removing installation directory..."
    Remove-Item -Path $NOOR_INSTALL_DIR -Recurse -Force
    Write-Success "Removed: $NOOR_INSTALL_DIR"
} else {
    Write-Warning "Installation directory not found: $NOOR_INSTALL_DIR"
}

# Remove terminal commands
$commands = @("noor.bat", "noor.ps1", "noor")
foreach ($cmd in $commands) {
    $cmdPath = Join-Path $NOOR_BIN_DIR $cmd
    if (Test-Path $cmdPath) {
        Write-Status "Removing $cmd..."
        Remove-Item -Path $cmdPath -Force
        Write-Success "Removed: $cmdPath"
    }
}

# Remove desktop shortcut
$desktopShortcut = "$env:USERPROFILE\Desktop\Noor (نور).lnk"
if (Test-Path $desktopShortcut) {
    Write-Status "Removing desktop shortcut..."
    Remove-Item -Path $desktopShortcut -Force
    Write-Success "Removed: $desktopShortcut"
}

# Remove Start Menu shortcut
$startMenuShortcut = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Noor (نور).lnk"
if (Test-Path $startMenuShortcut) {
    Write-Status "Removing Start Menu shortcut..."
    Remove-Item -Path $startMenuShortcut -Force
    Write-Success "Removed: $startMenuShortcut"
}

# Remove from PATH
Write-Status "Removing from PATH..."
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -like "*$NOOR_BIN_DIR*") {
    $newPath = ($userPath -split ';' | Where-Object { $_ -ne $NOOR_BIN_DIR }) -join ';'
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Success "Removed from PATH"
} else {
    Write-Info "Not found in PATH"
}

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                  ✅ Uninstall Complete!                        ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  Note: Please restart PowerShell/Command Prompt for PATH changes." -ForegroundColor Yellow
Write-Host ""
