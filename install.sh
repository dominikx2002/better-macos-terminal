#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Kolory ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BOLD='\033[1m'; NC='\033[0m'
info()    { echo -e "${BOLD}==>${NC} $*"; }
ok()      { echo -e "  ${GREEN}✓${NC}  $*"; }
step()    { echo -e "  ${YELLOW}->${NC}  $*"; }
err()     { echo -e "  ${RED}✗${NC}  $*"; }

echo ""
echo -e "${BOLD}  jjk-terminal-macos — instalator${NC}"
echo    "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── 1. Homebrew ───────────────────────────────────────────────────────────────
info "Sprawdzam Homebrew..."
if ! command -v brew &>/dev/null; then
  err "Homebrew nie jest zainstalowany."
  echo ""
  echo "  Zainstaluj go poleceniem:"
  echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
  echo "  lub wejdź na: https://brew.sh"
  echo ""
  exit 1
fi
ok "Homebrew $(brew --version | head -1)"

# ── 2. Zależności brew ────────────────────────────────────────────────────────
info "Instaluję zależności (pominę już zainstalowane)..."

brew_install() {
  if brew list --formula "$1" &>/dev/null; then
    ok "$1 (już zainstalowany)"
  else
    step "brew install $1"
    brew install "$1" || { err "Nie udało się zainstalować $1"; exit 1; }
    ok "$1"
  fi
}

brew_cask_install() {
  if brew list --cask "$1" &>/dev/null; then
    ok "$1 (już zainstalowany)"
  else
    step "brew install --cask $1"
    brew install --cask "$1" || { err "Nie udało się zainstalować $1"; exit 1; }
    ok "$1"
  fi
}

brew_install fastfetch
brew_install chafa
brew_install imagemagick
brew_install zsh-autosuggestions
brew_install zsh-syntax-highlighting
brew_cask_install font-hack-nerd-font

# ── 3. Konfiguracja fastfetch ─────────────────────────────────────────────────
info "Konfiguruję fastfetch..."

FF_DIR="$HOME/.config/fastfetch"
mkdir -p "$FF_DIR"

cp "$SCRIPT_DIR/config.jsonc" "$FF_DIR/config.jsonc"
ok "config.jsonc → $FF_DIR/"

cp "$SCRIPT_DIR/launch.sh" "$FF_DIR/launch.sh"
chmod +x "$FF_DIR/launch.sh"
ok "launch.sh → $FF_DIR/ (chmod +x)"

# Kopiuj obrazy tylko jeśli folder istnieje i nie jest pusty
if [ -d "$SCRIPT_DIR/images" ] && [ -n "$(ls -A "$SCRIPT_DIR/images" 2>/dev/null)" ]; then
  mkdir -p "$FF_DIR/images"
  cp "$SCRIPT_DIR/images/"* "$FF_DIR/images/" 2>/dev/null || true
  ok "images/ → $FF_DIR/images/"
fi

# ── 4. Konfiguracja zsh ───────────────────────────────────────────────────────
info "Konfiguruję zsh..."

ZSHRC_SRC="$SCRIPT_DIR/dotfiles/zshrc"
ZSHRC="$HOME/.zshrc"
BACKUP=""

# Sprawdź czy ~/.zshrc już wskazuje na nasz plik
if [ -L "$ZSHRC" ] && [ "$(readlink "$ZSHRC")" = "$ZSHRC_SRC" ]; then
  ok "~/.zshrc już wskazuje na repo — symlink odświeżony"
else
  # Coś istnieje (plik lub inny symlink) — zawsze rób backup przed nadpisaniem
  if [ -L "$ZSHRC" ] || [ -f "$ZSHRC" ]; then
    BACKUP="${ZSHRC}.backup.$(date +%Y%m%d%H%M%S)"
    cp "$ZSHRC" "$BACKUP"
    ok "Backup → $BACKUP"
  fi
fi

# Utwórz symlink (ln -sf: nadpisuje istniejący symlink, bezpieczne)
ln -sf "$ZSHRC_SRC" "$ZSHRC"
ok "Symlink ~/.zshrc → $ZSHRC_SRC"

# ── 5. Podsumowanie ───────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  Instalacja zakończona pomyślnie!${NC}"
echo    "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
if [ -n "$BACKUP" ]; then
  echo -e "  ${YELLOW}Backup poprzedniego ~/.zshrc:${NC}"
  echo    "    $BACKUP"
  echo ""
fi
echo    "  Co dalej:"
echo    ""
echo    "  1. Ustaw czcionkę w Terminal.app:"
echo    "       Terminal → Ustawienia → Profile → Czcionka"
echo -e "       Wybierz: ${BOLD}Hack Nerd Font${NC} (rozmiar wg uznania, np. 13)"
echo    ""
echo    "  2. Załaduj nową konfigurację zsh:"
echo -e "       ${BOLD}source ~/.zshrc${NC}"
echo    "     lub po prostu otwórz nowy terminal."
echo    ""
echo    "  3. Fastfetch uruchomi się automatycznie przy każdym"
echo    "     otwarciu nowego terminala."
echo    "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
