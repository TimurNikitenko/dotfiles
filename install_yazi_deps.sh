#!/usr/bin/env bash
set -e

# ==============================================================================
# Installer for Yazi Optional Dependencies on Ubuntu 24.04+
# ==============================================================================
# Skipped: yazi, fzf (already installed by user)
#
# Packages to install:
# 1. file (type detection)
# 2. ffmpeg & ffmpegthumbnailer (video thumbnails)
# 3. 7zip & p7zip-full (archive extraction & preview, non-standalone)
# 4. jq (JSON preview)
# 5. poppler-utils (PDF preview via pdftoppm)
# 6. fd-find -> symlinked to fd (file search)
# 7. ripgrep (rg: file content search)
# 8. zoxide (directory navigation)
# 9. wl-clipboard, xclip, xsel (clipboard integration)
# 10. resvg (SVG preview, precompiled standalone binary)
# 11. ImageMagick >= 7.1.1 (Font, HEIC, JPEG XL preview via official AppImage)
# 12. JetBrainsMono Nerd Font (icons for WezTerm / Yazi)
# ==============================================================================

echo "===> [1/4] Updating apt and installing standard repositories packages..."
sudo apt-get update
sudo apt-get install -y \
    file \
    ffmpeg \
    ffmpegthumbnailer \
    7zip \
    p7zip-full \
    jq \
    poppler-utils \
    fd-find \
    ripgrep \
    zoxide \
    wl-clipboard \
    xclip \
    xsel \
    libfuse2t64 \
    curl \
    tar

# Ensure fd points to fdfind (Debian/Ubuntu installs fd as fdfind)
if command -v fdfind >/dev/null 2>&1; then
    sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
    echo "  -> Linked fd -> $(command -v fdfind)"
fi

echo "===> [2/4] Installing ImageMagick 7 (>= 7.1.1 required by Yazi)..."
# Ubuntu 24.04 only provides ImageMagick 6 via apt. We install the official IM7 binary.
IMAGEMAGICK_URL="https://github.com/ImageMagick/ImageMagick/releases/download/7.1.2-31/ImageMagick-7.1.2-31-gcc-x86_64.AppImage"
echo "  -> Downloading ImageMagick 7 AppImage..."
sudo curl -fsSL "$IMAGEMAGICK_URL" -o /usr/local/bin/magick
sudo chmod +x /usr/local/bin/magick
echo "  -> ImageMagick installed to /usr/local/bin/magick"

echo "===> [3/4] Installing resvg (for SVG preview)..."
RESVG_URL="https://github.com/cargo-bins/cargo-quickinstall/releases/download/resvg-0.48.1/resvg-0.48.1-x86_64-unknown-linux-gnu.tar.gz"
echo "  -> Downloading resvg prebuilt binary..."
curl -fsSL "$RESVG_URL" | sudo tar -xz -C /usr/local/bin/
sudo chmod +x /usr/local/bin/resvg
echo "  -> resvg installed to /usr/local/bin/resvg"

echo "===> [4/4] Installing JetBrainsMono Nerd Font (recommended icons)..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
if ! fc-list : family | grep -iq "JetBrainsMono Nerd Font"; then
    echo "  -> Downloading JetBrainsMono Nerd Font..."
    curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz" -o /tmp/JetBrainsMono.tar.xz
    tar -xf /tmp/JetBrainsMono.tar.xz -C "$FONT_DIR"
    rm -f /tmp/JetBrainsMono.tar.xz
    fc-cache -f "$FONT_DIR"
    echo "  -> JetBrainsMono Nerd Font installed."
else
    echo "  -> JetBrainsMono Nerd Font is already installed."
fi

# Ensure zoxide is initialized in zsh if not already present
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ] && ! grep -q 'zoxide init zsh' "$ZSHRC"; then
    echo '' >> "$ZSHRC"
    echo '# zoxide shell integration for Yazi & jumping' >> "$ZSHRC"
    echo 'eval "$(zoxide init zsh)"' >> "$ZSHRC"
    echo "  -> Added 'eval \"\$(zoxide init zsh)\"' to ~/.zshrc"
fi

echo ""
echo "=========================================================="
echo "✅ All Yazi dependencies successfully installed!"
echo "Verification:"
for cmd in file ffmpeg 7z 7zz jq pdftoppm fd rg zoxide resvg magick wl-copy xclip; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "  [OK] $cmd -> $(command -v "$cmd")"
    else
        echo "  [MISSING] $cmd"
    fi
done
echo "=========================================================="
