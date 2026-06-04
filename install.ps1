# Noor (نور) - Islamic Desktop Application Installer (Windows)
# ============================================================
# Supports: Windows PowerShell, Windows Terminal, Command Prompt
# Usage:
#   Remote:  irm https://raw.githubusercontent.com/dev0math/noor-islamic-desktop/main/install.ps1 | iex
#   Local:   .\install.ps1
# ============================================================

$ErrorActionPreference = "Stop"

$NOOR_VERSION = "3.0.1"
$NOOR_REPO = "https://github.com/dev0math/noor-islamic-desktop"
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

function Write-Error($msg) {
    Write-Host "[✗] $msg" -ForegroundColor Red
}

function Write-Info($msg) {
    Write-Host "[i] $msg" -ForegroundColor DarkCyan
}

# ============================================================
# Check PowerShell Version
# ============================================================
function Check-PowerShellVersion {
    $psVersion = $PSVersionTable.PSVersion
    Write-Info "PowerShell version: $($psVersion.Major).$($psVersion.Minor)"

    if ($psVersion.Major -lt 5) {
        Write-Error "PowerShell 5.0 or higher is required. You have $($psVersion.Major).$($psVersion.Minor)"
        Write-Info "Please upgrade PowerShell: https://docs.microsoft.com/powershell/scripting/install/installing-powershell"
        exit 1
    }
}

# ============================================================
# Detect Windows Environment
# ============================================================
function Detect-Environment {
    $script:IsWindows = $true
    $script:IsWindowsTerminal = $false
    $script:IsPowerShellCore = $PSVersionTable.PSEdition -eq "Core"

    # Check if running in Windows Terminal
    if ($env:WT_SESSION -or $env:WT_PROFILE_ID) {
        $script:IsWindowsTerminal = $true
        Write-Info "Detected: Windows Terminal"
    }

    # Check Windows version
    $osInfo = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
    if ($osInfo) {
        Write-Info "Windows: $($osInfo.Caption) ($($osInfo.OSArchitecture))"
    }

    Write-Success "Windows environment detected"
}

# ============================================================
# Check & Install Dependencies
# ============================================================
function Check-NodeJS {
    Write-Status "Checking Node.js..."
    try {
        $nodeVersion = node --version 2>$null
        if ($nodeVersion) {
            Write-Success "Node.js found: $nodeVersion"
        } else {
            throw "Node.js not found"
        }
    } catch {
        Write-Warning "Node.js not found."
        Write-Info "Please install Node.js from: https://nodejs.org"
        Write-Info "Download the LTS version and run the installer."
        Write-Info "After installation, restart PowerShell and run this script again."

        $openBrowser = Read-Host "Open Node.js download page in browser? (Y/n)"
        if ($openBrowser -ne 'n' -and $openBrowser -ne 'N') {
            Start-Process "https://nodejs.org"
        }
        exit 1
    }

    try {
        $npmVersion = npm --version 2>$null
        if ($npmVersion) {
            Write-Success "npm found: v$npmVersion"
        } else {
            throw "npm not found"
        }
    } catch {
        Write-Error "npm not found. Please reinstall Node.js (includes npm)."
        exit 1
    }
}

function Check-Git {
    Write-Status "Checking Git..."
    try {
        $gitVersion = git --version 2>$null
        if ($gitVersion) {
            Write-Success "Git found: $gitVersion"
        } else {
            throw "Git not found"
        }
    } catch {
        Write-Warning "Git not found."
        Write-Info "Please install Git for Windows: https://git-scm.com/download/win"
        Write-Info "Or use Git Bash which includes Git."

        $openBrowser = Read-Host "Open Git download page in browser? (Y/n)"
        if ($openBrowser -ne 'n' -and $openBrowser -ne 'N') {
            Start-Process "https://git-scm.com/download/win"
        }
        exit 1
    }
}

# ============================================================
# Create Directories
# ============================================================
function Create-Directories {
    Write-Status "Creating directories..."
    New-Item -ItemType Directory -Force -Path $NOOR_INSTALL_DIR | Out-Null
    New-Item -ItemType Directory -Force -Path $NOOR_BIN_DIR | Out-Null
    Write-Success "Directories created"
}

# ============================================================
# Get Source Code (Local or Remote)
# ============================================================
function Get-Source {
    Write-Status "Getting source code..."

    # Detect if running from local source
    $scriptDir = $PSScriptRoot
    $localSource = $false

    if ($scriptDir -and (Test-Path "$scriptDir\package.json") -and (Test-Path "$scriptDir\src")) {
        Write-Info "Local source detected: $scriptDir"
        $localSource = $true
    }

    if ($localSource) {
        # Copy from local source
        Write-Status "Copying from local source..."
        Remove-Item -Path "$NOOR_INSTALL_DIR\*" -Recurse -Force -ErrorAction SilentlyContinue
        Copy-Item -Path "$scriptDir\*" -Destination $NOOR_INSTALL_DIR -Recurse -Force

        # Cleanup
        Remove-Item -Path "$NOOR_INSTALL_DIR\install.sh" -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$NOOR_INSTALL_DIR\install.ps1" -Force -ErrorAction SilentlyContinue

        Write-Success "Files copied from local source"
    } else {
        # Clone from GitHub
        Write-Status "Cloning from GitHub: $NOOR_REPO"
        if (Test-Path "$NOOR_INSTALL_DIR\.git") {
            Write-Info "Existing installation found. Updating..."
            Set-Location $NOOR_INSTALL_DIR
            git fetch origin
            git reset --hard origin/main
        } else {
            Remove-Item -Recurse -Force $NOOR_INSTALL_DIR -ErrorAction SilentlyContinue
            git clone --depth 1 "$NOOR_REPO.git" $NOOR_INSTALL_DIR
        }
        Write-Success "Repository cloned"
    }
}

# ============================================================
# Install Dependencies
# ============================================================
function Install-Dependencies {
    Write-Status "Installing npm dependencies..."
    Set-Location $NOOR_INSTALL_DIR
    npm install
    Write-Success "Dependencies installed"
}

# ============================================================
# Build Application
# ============================================================
function Build-App {
    Write-Status "Building Noor application..."
    Set-Location $NOOR_INSTALL_DIR

    # Try Windows build first, fallback to generic
    npm run packwin 2>$null
    if ($LASTEXITCODE -ne 0) {
        npm run dist 2>$null
        if ($LASTEXITCODE -ne 0) {
            npm run pack
        }
    }

    Write-Success "Build complete"
}

# ============================================================
# Create Desktop Shortcut
# ============================================================
function Create-DesktopShortcut {
    Write-Status "Creating desktop shortcut..."

    $WshShell = New-Object -comObject WScript.Shell
    $shortcutPath = "$env:USERPROFILE\Desktop\Noor (نور).lnk"
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)

    # Find the built executable
    $exePaths = @(
        "$NOOR_INSTALL_DIR\dist\win-unpacked\Noor.exe",
        "$NOOR_INSTALL_DIR\dist\win-ia32-unpacked\Noor.exe",
        "$NOOR_INSTALL_DIR\dist\win-x64\Noor.exe"
    )

    $exePath = $null
    foreach ($path in $exePaths) {
        if (Test-Path $path) {
            $exePath = $path
            break
        }
    }

    if ($exePath) {
        $Shortcut.TargetPath = $exePath
        $Shortcut.WorkingDirectory = (Split-Path -Parent $exePath)
        Write-Info "Using built executable: $exePath"
    } else {
        # Fallback to npm start via PowerShell
        $Shortcut.TargetPath = "powershell.exe"
        $Shortcut.Arguments = "-WindowStyle Hidden -Command `"cd '$NOOR_INSTALL_DIR'; npm start`""
        $Shortcut.WorkingDirectory = $NOOR_INSTALL_DIR
        Write-Info "Using npm start fallback"
    }

    # Set icon
    $iconPaths = @(
        "$NOOR_INSTALL_DIR\src\build\icons\icon.ico",
        "$NOOR_INSTALL_DIR\src\build\icons\icon.png"
    )
    foreach ($iconPath in $iconPaths) {
        if (Test-Path $iconPath) {
            $Shortcut.IconLocation = $iconPath
            break
        }
    }

    $Shortcut.Save()
    Write-Success "Desktop shortcut created: $shortcutPath"

    # Also create Start Menu shortcut
    $startMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Noor (نور).lnk"
    $StartMenuShortcut = $WshShell.CreateShortcut($startMenuPath)
    $StartMenuShortcut.TargetPath = $Shortcut.TargetPath
    $StartMenuShortcut.Arguments = $Shortcut.Arguments
    $StartMenuShortcut.WorkingDirectory = $Shortcut.WorkingDirectory
    $StartMenuShortcut.IconLocation = $Shortcut.IconLocation
    $StartMenuShortcut.Save()
    Write-Success "Start Menu shortcut created"
}

# ============================================================
# Create Terminal Command
# ============================================================
function Create-TerminalCommand {
    Write-Status "Creating terminal command 'noor'..."

    # Create noor.bat for Command Prompt
    $batContent = @"
@echo off
set NOOR_DIR=%USERPROFILE%\.local\share\noor

if exist "%NOOR_DIR%\dist\win-unpacked\Noor.exe" (
    start "" "%NOOR_DIR%\dist\win-unpacked\Noor.exe" %*
) else if exist "%NOOR_DIR%\dist\win-ia32-unpacked\Noor.exe" (
    start "" "%NOOR_DIR%\dist\win-ia32-unpacked\Noor.exe" %*
) else if exist "%NOOR_DIR%\dist\win-x64\Noor.exe" (
    start "" "%NOOR_DIR%\dist\win-x64\Noor.exe" %*
) else (
    cd /d "%NOOR_DIR%"
    npm start -- %*
)
"@

    Set-Content -Path "$NOOR_BIN_DIR\noor.bat" -Value $batContent
    Write-Success "Command 'noor.bat' created for Command Prompt"

    # Create noor.ps1 for PowerShell
    $ps1Content = @'
# Noor launcher for PowerShell
$NOOR_DIR = "$env:USERPROFILE\.local\share\noor"

$exePaths = @(
    "$NOOR_DIR\dist\win-unpacked\Noor.exe",
    "$NOOR_DIR\dist\win-ia32-unpacked\Noor.exe",
    "$NOOR_DIR\dist\win-x64\Noor.exe"
)

$exePath = $null
foreach ($path in $exePaths) {
    if (Test-Path $path) {
        $exePath = $path
        break
    }
}

if ($exePath) {
    & $exePath @args
} else {
    Set-Location $NOOR_DIR
    npm start -- @args
}
'@

    Set-Content -Path "$NOOR_BIN_DIR\noor.ps1" -Value $ps1Content
    Write-Success "Command 'noor.ps1' created for PowerShell"

    # Add to PATH (User environment)
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($userPath -notlike "*$NOOR_BIN_DIR*") {
        [Environment]::SetEnvironmentVariable("Path", "$userPath;$NOOR_BIN_DIR", "User")
        Write-Warning "Added noor to PATH. Please restart your terminal or PowerShell."
    } else {
        Write-Info "noor already in PATH"
    }

    # Also update current session PATH
    $env:Path = "$env:Path;$NOOR_BIN_DIR"
}

# ============================================================
# Main Installation
# ============================================================
function Main {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                                                              ║" -ForegroundColor Green
    Write-Host "║         🌙 Noor (نور) - Islamic Desktop App                ║" -ForegroundColor Green
    Write-Host "║                                                              ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""

    Check-PowerShellVersion
    Detect-Environment
    Check-NodeJS
    Check-Git
    Create-Directories
    Get-Source
    Install-Dependencies
    Build-App
    Create-DesktopShortcut
    Create-TerminalCommand

    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                    ✅ Installation Complete!                   ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Usage:" -ForegroundColor Blue
    Write-Host "    noor              Launch Noor from terminal" -ForegroundColor Yellow
    Write-Host "    noor --hidden     Launch hidden/minimized to tray" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Desktop:" -ForegroundColor Blue
    Write-Host "    Look for 'Noor (نور)' on your Desktop" -ForegroundColor Yellow
    Write-Host "    And in your Start Menu" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Command Prompt:" -ForegroundColor Blue
    Write-Host "    Run: noor.bat" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  PowerShell:" -ForegroundColor Blue
    Write-Host "    Run: noor.ps1" -ForegroundColor Yellow
    Write-Host "    Or:  noor (after restarting PowerShell)" -ForegroundColor Yellow
    Write-Host ""

    # Try to launch
    $exePath = "$NOOR_INSTALL_DIR\dist\win-unpacked\Noor.exe"
    if (Test-Path $exePath) {
        Write-Status "Launching Noor..."
        Start-Process $exePath
    } else {
        Write-Info "Please restart PowerShell or Command Prompt"
        Write-Info "Then run: noor"
    }
    
    Write-Host ""
    Write-Info "To uninstall Noor later, run: .\uninstall.ps1"
}

Main
