#!/bin/bash

# ============================================================
# Noor (نور) - Uninstaller
# ============================================================
# Usage: bash uninstall.sh
# ============================================================

set -e

NOOR_INSTALL_DIR="$HOME/.local/share/noor"
NOOR_BIN_DIR="$HOME/.local/bin"
NOOR_DESKTOP_DIR="$HOME/.local/share/applications"
NOOR_ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[Noor]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# ============================================================
# Main Uninstall
# ============================================================
echo ""
echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║                                                              ║${NC}"
echo -e "${YELLOW}║         🗑️  Noor (نور) - Uninstaller                        ║${NC}"
echo -e "${YELLOW}║                                                              ║${NC}"
echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

print_status "This will remove Noor from your system."
read -p "Are you sure? (y/N): " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    print_status "Uninstall cancelled."
    exit 0
fi

# Remove installation directory
if [ -d "$NOOR_INSTALL_DIR" ]; then
    print_status "Removing installation directory..."
    rm -rf "$NOOR_INSTALL_DIR"
    print_success "Removed: $NOOR_INSTALL_DIR"
else
    print_warning "Installation directory not found: $NOOR_INSTALL_DIR"
fi

# Remove terminal command
if [ -f "$NOOR_BIN_DIR/noor" ]; then
    print_status "Removing terminal command..."
    rm -f "$NOOR_BIN_DIR/noor"
    print_success "Removed: $NOOR_BIN_DIR/noor"
fi

if [ -f "$NOOR_BIN_DIR/noor.bat" ]; then
    print_status "Removing Windows batch command..."
    rm -f "$NOOR_BIN_DIR/noor.bat"
    print_success "Removed: $NOOR_BIN_DIR/noor.bat"
fi

if [ -f "$NOOR_BIN_DIR/noor.ps1" ]; then
    print_status "Removing PowerShell command..."
    rm -f "$NOOR_BIN_DIR/noor.ps1"
    print_success "Removed: $NOOR_BIN_DIR/noor.ps1"
fi

# Remove desktop entry (Linux)
if [ -f "$NOOR_DESKTOP_DIR/noor.desktop" ]; then
    print_status "Removing desktop entry..."
    rm -f "$NOOR_DESKTOP_DIR/noor.desktop"
    print_success "Removed: $NOOR_DESKTOP_DIR/noor.desktop"
fi

# Remove icon (Linux)
if [ -f "$NOOR_ICON_DIR/noor.png" ]; then
    print_status "Removing icon..."
    rm -f "$NOOR_ICON_DIR/noor.png"
    print_success "Removed: $NOOR_ICON_DIR/noor.png"
fi

# Update desktop database (Linux)
if command -v update-desktop-database &> /dev/null; then
    print_status "Updating desktop database..."
    update-desktop-database "$NOOR_DESKTOP_DIR" 2>/dev/null || true
    print_success "Desktop database updated"
fi

# Remove from PATH in shell configs
print_status "Cleaning PATH from shell configs..."
for rc_file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.profile"; do
    if [ -f "$rc_file" ]; then
        sed -i "s|export PATH=\"$NOOR_BIN_DIR:\$PATH\"||g" "$rc_file" 2>/dev/null || true
    fi
done
print_success "Shell configs cleaned"

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                  ✅ Uninstall Complete!                        ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${YELLOW}Note:${NC} Please restart your terminal for PATH changes to take effect."
echo ""
