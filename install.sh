#!/bin/bash

# ============================================================
# Noor (نور) - Islamic Desktop Application Installer
# ============================================================
# Supports: Linux, macOS, Windows (Git Bash/WSL), WSL
# Usage:
#   Local:   bash install.sh
#   Remote:  curl -sL https://raw.githubusercontent.com/dev0math/noor-islamic-desktop/main/install.sh | bash
# ============================================================

set -e

NOOR_VERSION="3.0.1"
NOOR_REPO="https://github.com/dev0math/noor-islamic-desktop"
NOOR_INSTALL_DIR="$HOME/.local/share/noor"
NOOR_BIN_DIR="$HOME/.local/bin"
NOOR_DESKTOP_DIR="$HOME/.local/share/applications"
NOOR_ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[Noor]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[i]${NC} $1"
}

# ============================================================
# Detect Operating System
# ============================================================
detect_os() {
    OS="unknown"
    IS_WINDOWS=false
    IS_MACOS=false
    IS_LINUX=false
    IS_WSL=false

    # Check for WSL first (Windows Subsystem for Linux)
    if [[ -f /proc/version ]] && grep -q "Microsoft\|WSL" /proc/version 2>/dev/null; then
        IS_WSL=true
        IS_LINUX=true
        OS="wsl"
        print_info "Detected: Windows Subsystem for Linux (WSL)"
        return
    fi

    # Check OSTYPE
    case "$OSTYPE" in
        linux-gnu*|linux-musl*)
            IS_LINUX=true
            if command -v apt-get &> /dev/null; then
                OS="linux-deb"
            elif command -v pacman &> /dev/null; then
                OS="linux-arch"
            elif command -v dnf &> /dev/null || command -v yum &> /dev/null; then
                OS="linux-rpm"
            elif command -v zypper &> /dev/null; then
                OS="linux-suse"
            else
                OS="linux"
            fi
            ;;
        darwin*)
            IS_MACOS=true
            OS="macos"
            ;;
        msys*|cygwin*|win32*)
            IS_WINDOWS=true
            OS="windows"
            ;;
        *)
            # Fallback checks
            if [[ "$OS" == "Windows_NT" ]] || [[ -d "/c/Windows" ]] || [[ -d "/mnt/c/Windows" ]]; then
                IS_WINDOWS=true
                OS="windows"
            elif [[ $(uname -s) == "Darwin" ]]; then
                IS_MACOS=true
                OS="macos"
            elif [[ $(uname -s) == "Linux" ]]; then
                IS_LINUX=true
                OS="linux"
            else
                print_error "Operating system not supported: OSTYPE=$OSTYPE, OS=$OS"
                print_info "Supported systems: Linux, macOS, Windows (Git Bash, WSL)"
                exit 1
            fi
            ;;
    esac

    print_info "Detected OS: $OS"
}

# ============================================================
# Check & Install Dependencies
# ============================================================
check_dependencies() {
    print_status "Checking dependencies..."

    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_warning "Node.js not found."
        if [[ "$IS_LINUX" == true ]] || [[ "$IS_MACOS" == true ]]; then
            install_nodejs_unix
        elif [[ "$IS_WINDOWS" == true ]]; then
            print_error "Please install Node.js manually: https://nodejs.org"
            print_info "Download and run the Windows installer, then re-run this script."
            exit 1
        fi
    else
        NODE_VERSION=$(node --version 2>/dev/null | sed 's/v//')
        print_success "Node.js found: v$NODE_VERSION"
    fi

    # Check npm
    if ! command -v npm &> /dev/null; then
        print_error "npm not found. Please install Node.js (includes npm)."
        exit 1
    else
        print_success "npm found"
    fi

    # Check Git
    if ! command -v git &> /dev/null; then
        print_warning "Git not found."
        if [[ "$IS_LINUX" == true ]] || [[ "$IS_MACOS" == true ]]; then
            install_git_unix
        elif [[ "$IS_WINDOWS" == true ]]; then
            print_error "Please install Git for Windows: https://git-scm.com/download/win"
            print_info "Or use Git Bash which includes Git."
            exit 1
        fi
    else
        print_success "Git found"
    fi

    print_success "All dependencies satisfied"
}

install_nodejs_unix() {
    print_status "Installing Node.js..."
    if [[ "$OS" == "linux-deb" ]]; then
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - 2>/dev/null || {
            print_error "Failed to setup NodeSource. Please install manually."
            exit 1
        }
        sudo apt-get install -y nodejs
    elif [[ "$OS" == "linux-arch" ]]; then
        sudo pacman -S --noconfirm nodejs npm
    elif [[ "$OS" == "linux-rpm" ]]; then
        sudo dnf install -y nodejs npm
    elif [[ "$OS" == "linux-suse" ]]; then
        sudo zypper install -y nodejs npm
    elif [[ "$OS" == "macos" ]]; then
        if command -v brew &> /dev/null; then
            brew install node
        else
            print_error "Homebrew not found. Please install from https://brew.sh"
            exit 1
        fi
    else
        print_error "Cannot auto-install Node.js on this system."
        print_info "Please install manually: https://nodejs.org"
        exit 1
    fi
    print_success "Node.js installed"
}

install_git_unix() {
    print_status "Installing Git..."
    if [[ "$OS" == "linux-deb" ]]; then
        sudo apt-get install -y git
    elif [[ "$OS" == "linux-arch" ]]; then
        sudo pacman -S --noconfirm git
    elif [[ "$OS" == "linux-rpm" ]]; then
        sudo dnf install -y git
    elif [[ "$OS" == "linux-suse" ]]; then
        sudo zypper install -y git
    elif [[ "$OS" == "macos" ]]; then
        brew install git
    fi
    print_success "Git installed"
}

# ============================================================
# Create Directories
# ============================================================
create_directories() {
    print_status "Creating directories..."

    if [[ "$IS_WINDOWS" == true ]]; then
        # Windows paths (Git Bash / MSYS)
        NOOR_INSTALL_DIR="$HOME/.local/share/noor"
        NOOR_BIN_DIR="$HOME/.local/bin"
    fi

    mkdir -p "$NOOR_INSTALL_DIR"
    mkdir -p "$NOOR_BIN_DIR"

    if [[ "$IS_LINUX" == true ]] && [[ "$IS_WSL" == false ]]; then
        mkdir -p "$NOOR_DESKTOP_DIR"
        mkdir -p "$NOOR_ICON_DIR"
    fi

    print_success "Directories created"
}

# ============================================================
# Get Source Code (Local or Remote)
# ============================================================
get_source() {
    print_status "Getting source code..."

    # Detect if running from local source
    SCRIPT_DIR=""
    if [[ -n "${BASH_SOURCE[0]}" ]]; then
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    fi

    LOCAL_SOURCE=false
    if [[ -n "$SCRIPT_DIR" ]] && [[ -f "$SCRIPT_DIR/package.json" ]] && [[ -d "$SCRIPT_DIR/src" ]]; then
        print_info "Local source detected: $SCRIPT_DIR"
        LOCAL_SOURCE=true
    fi

    if [[ "$LOCAL_SOURCE" == true ]]; then
        # Copy from local source
        print_status "Copying from local source..."
        rm -rf "$NOOR_INSTALL_DIR"/*
        cp -r "$SCRIPT_DIR"/* "$NOOR_INSTALL_DIR/"

        # Remove install scripts from installed copy (optional cleanup)
        rm -f "$NOOR_INSTALL_DIR/install.sh"
        rm -f "$NOOR_INSTALL_DIR/install.ps1"

        print_success "Files copied from local source"
    else
        # Clone from GitHub
        print_status "Cloning from GitHub: $NOOR_REPO"
        if [ -d "$NOOR_INSTALL_DIR/.git" ]; then
            print_info "Existing installation found. Updating..."
            cd "$NOOR_INSTALL_DIR"
            git fetch origin
            git reset --hard origin/main
        else
            rm -rf "$NOOR_INSTALL_DIR"
            git clone --depth 1 "$NOOR_REPO.git" "$NOOR_INSTALL_DIR" || {
                print_error "Failed to clone from GitHub."
                print_info "Please either:"
                print_info "  1. Create the GitHub repo: https://github.com/new"
                print_info "  2. Run this script from the project directory (where package.json exists)"
                exit 1
            }
        fi
        print_success "Repository cloned"
    fi
}

# ============================================================
# Install npm Dependencies
# ============================================================
install_npm_deps() {
    print_status "Installing npm dependencies..."
    cd "$NOOR_INSTALL_DIR"
    npm install
    print_success "Dependencies installed"
}

# ============================================================
# Build Application
# ============================================================
build_app() {
    print_status "Building Noor application..."
    cd "$NOOR_INSTALL_DIR"

    if [[ "$IS_WINDOWS" == true ]]; then
        npm run packwin || npm run dist || npm run pack
    elif [[ "$IS_LINUX" == true ]]; then
        npm run packlinux || npm run dist || npm run pack
    elif [[ "$IS_MACOS" == true ]]; then
        npm run dist || npm run pack
    else
        npm run dist || npm run pack
    fi

    print_success "Build complete"
}

# ============================================================
# Create Desktop Integration
# ============================================================
create_desktop_integration() {
    if [[ "$IS_LINUX" == true ]] && [[ "$IS_WSL" == false ]]; then
        print_status "Creating desktop integration (Linux)..."

        APP_PATH=""
        if ls "$NOOR_INSTALL_DIR/dist/Noor-"*.AppImage &>/dev/null; then
            APP_PATH=$(ls "$NOOR_INSTALL_DIR/dist/Noor-"*.AppImage | head -1)
        elif [ -f "$NOOR_INSTALL_DIR/dist/linux-unpacked/noor" ]; then
            APP_PATH="$NOOR_INSTALL_DIR/dist/linux-unpacked/noor"
        elif [ -f "$NOOR_INSTALL_DIR/dist/linux-unpacked/Noor" ]; then
            APP_PATH="$NOOR_INSTALL_DIR/dist/linux-unpacked/Noor"
        fi

        if [ -n "$APP_PATH" ]; then
            cat > "$NOOR_DESKTOP_DIR/noor.desktop" << EOF
[Desktop Entry]
Name=Noor (نور)
Comment=Islamic Desktop Application
Exec=$APP_PATH
Icon=$NOOR_INSTALL_DIR/src/build/icons/icon.png
Type=Application
Categories=Education;Religion;
Terminal=false
StartupNotify=true
Keywords=islam;quran;prayer;adhkar;
EOF
            chmod +x "$NOOR_DESKTOP_DIR/noor.desktop"

            if [ -f "$NOOR_INSTALL_DIR/src/build/icons/icon.png" ]; then
                cp "$NOOR_INSTALL_DIR/src/build/icons/icon.png" "$NOOR_ICON_DIR/noor.png" 2>/dev/null || true
            fi

            if command -v update-desktop-database &> /dev/null; then
                update-desktop-database "$NOOR_DESKTOP_DIR" 2>/dev/null || true
            fi

            print_success "Desktop entry created"
        else
            print_warning "Could not find built executable for desktop entry"
        fi

    elif [[ "$IS_MACOS" == true ]]; then
        print_status "Creating macOS app link..."
        # macOS .app bundle would be in dist/
        if ls "$NOOR_INSTALL_DIR/dist/Noor-"*.dmg &>/dev/null || ls "$NOOR_INSTALL_DIR/dist/mac/"*.app &>/dev/null 2>/dev/null; then
            print_success "macOS build found. Install the .dmg or .app manually."
        else
            print_info "Run with: cd $NOOR_INSTALL_DIR && npm start"
        fi

    elif [[ "$IS_WINDOWS" == true ]]; then
        print_status "Creating Windows shortcuts..."

        # Create noor.bat command
        cat > "$NOOR_BIN_DIR/noor.bat" << 'EOF'
@echo off
set NOOR_DIR=%USERPROFILE%\.local\share\noor
if exist "%NOOR_DIR%\dist\win-unpacked\Noor.exe" (
    start "" "%NOOR_DIR%\dist\win-unpacked\Noor.exe" %*
) else if exist "%NOOR_DIR%\dist\win-ia32-unpacked\Noor.exe" (
    start "" "%NOOR_DIR%\dist\win-ia32-unpacked\Noor.exe" %*
) else (
    cd /d "%NOOR_DIR%"
    npm start -- %*
)
EOF
        print_success "Windows batch command created"

        # Note: PowerShell script handles .lnk creation better
        print_info "For desktop shortcut, run install.ps1 on Windows PowerShell"
    fi
}

# ============================================================
# Create Terminal Command
# ============================================================
create_terminal_command() {
    print_status "Creating terminal command 'noor'..."

    if [[ "$IS_WINDOWS" == true ]]; then
        # Windows: create noor.bat (already done above) + shell script for Git Bash
        cat > "$NOOR_BIN_DIR/noor" << 'EOF'
#!/bin/bash
# Noor launcher for Git Bash / MSYS
NOOR_DIR="$HOME/.local/share/noor"
if [ -f "$NOOR_DIR/dist/win-unpacked/Noor.exe" ]; then
    "$NOOR_DIR/dist/win-unpacked/Noor.exe" "$@" &
elif [ -f "$NOOR_DIR/dist/win-ia32-unpacked/Noor.exe" ]; then
    "$NOOR_DIR/dist/win-ia32-unpacked/Noor.exe" "$@" &
else
    cd "$NOOR_DIR"
    npm start "$@"
fi
EOF
        chmod +x "$NOOR_BIN_DIR/noor"

    else
        # Linux / macOS / WSL
        cat > "$NOOR_BIN_DIR/noor" << 'EOF'
#!/bin/bash
NOOR_DIR="$HOME/.local/share/noor"
if [ -f "$NOOR_DIR/dist/linux-unpacked/noor" ]; then
    "$NOOR_DIR/dist/linux-unpacked/noor" "$@"
elif [ -f "$NOOR_DIR/dist/linux-unpacked/Noor" ]; then
    "$NOOR_DIR/dist/linux-unpacked/Noor" "$@"
elif ls "$NOOR_DIR/dist/Noor-"*.AppImage &>/dev/null; then
    APP_IMAGE=$(ls "$NOOR_INSTALL_DIR/dist/Noor-"*.AppImage | head -1)
    "$APP_IMAGE" "$@"
else
    cd "$NOOR_DIR"
    npm start "$@"
fi
EOF
        chmod +x "$NOOR_BIN_DIR/noor"
    fi

    # Add to PATH
    if [[ "$IS_WINDOWS" == true ]]; then
        # Git Bash PATH
        if [[ ":$PATH:" != *":$NOOR_BIN_DIR:"* ]]; then
            echo "export PATH=\"$NOOR_BIN_DIR:\$PATH\"" >> "$HOME/.bashrc"
            echo "export PATH=\"$NOOR_BIN_DIR:\$PATH\"" >> "$HOME/.zshrc" 2>/dev/null || true
            print_warning "Added to PATH. Please run: source ~/.bashrc or restart terminal"
        fi
    else
        # Linux / macOS
        SHELL_RC="$HOME/.bashrc"
        if [[ "$SHELL" == *"zsh"* ]] && [[ -f "$HOME/.zshrc" ]]; then
            SHELL_RC="$HOME/.zshrc"
        fi

        if ! grep -q "$NOOR_BIN_DIR" "$SHELL_RC" 2>/dev/null; then
            echo "export PATH=\"$NOOR_BIN_DIR:\$PATH\"" >> "$SHELL_RC"
            print_warning "Added $NOOR_BIN_DIR to PATH in $SHELL_RC"
            print_info "Run: source $SHELL_RC  (or restart terminal)"
        fi
    fi

    print_success "Command 'noor' created"
}

# ============================================================
# Main Installation
# ============================================================
main() {
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                              ║${NC}"
    echo -e "${GREEN}║         🌙 Noor (نور) - Islamic Desktop App                  ║${NC}"
    echo -e "${GREEN}║                                                              ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    detect_os
    check_dependencies
    create_directories
    get_source
    install_npm_deps
    build_app
    create_desktop_integration
    create_terminal_command

    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    ✅ Installation Complete!                   ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${BLUE}Usage:${NC}"
    echo -e "    ${YELLOW}noor${NC}              Launch Noor from terminal"
    echo -e "    ${YELLOW}noor --hidden${NC}     Launch hidden/minimized to tray"
    echo ""

    if [[ "$IS_LINUX" == true ]] && [[ "$IS_WSL" == false ]]; then
        echo -e "  ${BLUE}Desktop:${NC}"
        echo -e "    Find ${YELLOW}Noor (نور)${NC} in your applications menu"
        echo ""
    elif [[ "$IS_WINDOWS" == true ]]; then
        echo -e "  ${BLUE}Windows:${NC}"
        echo -e "    Run ${YELLOW}noor.bat${NC} from Command Prompt"
        echo -e "    Or run ${YELLOW}noor${NC} from Git Bash"
        echo -e "    For desktop shortcut, use PowerShell: ${YELLOW}install.ps1${NC}"
        echo ""
    elif [[ "$IS_MACOS" == true ]]; then
        echo -e "  ${BLUE}macOS:${NC}"
        echo -e "    Run ${YELLOW}noor${NC} from terminal"
        echo -e "    Or open the built .app from dist/"
        echo ""
    fi

    # Try to launch
    if command -v noor &> /dev/null; then
        print_status "Launching Noor..."
        noor &
    else
        print_info "Please restart your terminal or run: source ~/.bashrc"
        print_info "Then run: noor"
    fi
    
    echo ""
    print_info "To uninstall Noor later, run: bash uninstall.sh"
}

main "$@"
