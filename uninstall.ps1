# ============================================================
# Noor (نور) - Uninstaller (Windows)
# ============================================================
# Usage: .\uninstall.ps1
# ============================================================

$ErrorActionPreference = "Stop"

$NOOR_INSTALL_DIR = "$env:USERPROFILE\.local\share\noor"
$NOOR_BIN_DIR     = "$env:USERPROFILE\.local\bin"

function Write-Status ($msg) { Write-Host "[Noor] $msg" -ForegroundColor Cyan }
function Write-Ok     ($msg) { Write-Host "[ OK ] $msg" -ForegroundColor Green }
function Write-Warn   ($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Info   ($msg) { Write-Host "[INFO] $msg" -ForegroundColor DarkCyan }

Write-Host ""
Write-Host "================================================================" -ForegroundColor Yellow
Write-Host "              Noor (نور) - Uninstaller                          " -ForegroundColor Yellow
Write-Host "================================================================" -ForegroundColor Yellow
Write-Host ""

Write-Status "This will remove Noor and all its files from your system."
$confirm = Read-Host "Are you sure you want to continue? (y/N)"

if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Status "Uninstall cancelled."
    exit 0
}

Write-Host ""

# Remove installation directory
if (Test-Path $NOOR_INSTALL_DIR) {
    Write-Status "Removing installation directory..."
    Remove-Item -Path $NOOR_INSTALL_DIR -Recurse -Force
    Write-Ok "Removed: $NOOR_INSTALL_DIR"
} else {
    Write-Warn "Installation directory not found: $NOOR_INSTALL_DIR"
}

# Remove terminal command files
foreach ($cmd in @("noor.bat", "noor.ps1", "noor")) {
    $p = Join-Path $NOOR_BIN_DIR $cmd
    if (Test-Path $p) {
        Remove-Item -Path $p -Force
        Write-Ok "Removed: $p"
    }
}

# Remove desktop shortcut
$desktopShortcut = "$env:USERPROFILE\Desktop\Noor.lnk"
if (Test-Path $desktopShortcut) {
    Remove-Item -Path $desktopShortcut -Force
    Write-Ok "Removed desktop shortcut"
}

# Remove Start Menu shortcut
$startMenuShortcut = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Noor.lnk"
if (Test-Path $startMenuShortcut) {
    Remove-Item -Path $startMenuShortcut -Force
    Write-Ok "Removed Start Menu shortcut"
}

# Remove NOOR_BIN_DIR from user PATH
Write-Status "Updating PATH..."
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -like "*$NOOR_BIN_DIR*") {
    $newPath = ($userPath -split ';' | Where-Object { $_.Trim() -ne $NOOR_BIN_DIR }) -join ';'
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Ok "Removed from PATH"
} else {
    Write-Info "Entry not found in PATH — nothing to remove"
}

Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host "                    Uninstall Complete                          " -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Note: Restart PowerShell or Command Prompt for PATH changes to take effect." -ForegroundColor Yellow
Write-Host ""
