#!/usr/bin/env bash
#
# better-macos-terminal — instalator
#
# Obsługuje dwa menedżery pakietów:
#   • MacPorts  — zalecany na Macach z Intelem (Homebrew 7+ przeniósł Intela do Tier 3)
#   • Homebrew  — zalecany na Apple Silicon (M1/M2/M3/...)
#
# Wybór jest automatyczny, ale można go wymusić:
#   ./install.sh --macports
#   ./install.sh --brew

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Kolory ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BOLD='\033[1m'; NC='\033[0m'
info()    { echo -e "${BOLD}==>${NC} $*"; }
ok()      { echo -e "  ${GREEN}✓${NC}  $*"; }
step()    { echo -e "  ${YELLOW}->${NC}  $*"; }
warn()    { echo -e "  ${YELLOW}!${NC}  $*"; }
err()     { echo -e "  ${RED}✗${NC}  $*"; }

echo ""
echo -e "${BOLD}  better-macos-terminal — instalator${NC}"
echo    "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── 0. Argumenty ──────────────────────────────────────────────────────────────
FORCED=""
for arg in "$@"; do
  case "$arg" in
    --macports|--port) FORCED="macports" ;;
    --brew|--homebrew) FORCED="brew" ;;
    -h|--help)
      echo "Użycie: ./install.sh [--macports | --brew]"
      exit 0 ;;
    *) err "Nieznany argument: $arg"; exit 1 ;;
  esac
done

# ── 1. Wybór menedżera pakietów ───────────────────────────────────────────────
info "Wykrywam menedżer pakietów..."

ARCH="$(uname -m)"
# MacPorts po instalacji .pkg dopisuje /opt/local/bin do ~/.zprofile,
# ale w bieżącym (bash) procesie może go jeszcze nie być w PATH.
[ -x /opt/local/bin/port ] && export PATH="/opt/local/bin:/opt/local/sbin:$PATH"

HAS_BREW=false; command -v brew &>/dev/null && HAS_BREW=true
HAS_PORT=false; command -v port &>/dev/null && HAS_PORT=true

PM=""
if [ -n "$FORCED" ]; then
  PM="$FORCED"
elif [ "$ARCH" = "arm64" ] && $HAS_BREW; then
  PM="brew"
elif $HAS_PORT; then
  PM="macports"
elif $HAS_BREW; then
  PM="brew"
fi

if [ -z "$PM" ]; then
  err "Nie znaleziono ani MacPorts, ani Homebrew."
  echo ""
  if [ "$ARCH" = "arm64" ]; then
    echo "  Masz Apple Silicon — zainstaluj Homebrew:"
    echo "    /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
  else
    echo "  Masz Maca z Intelem — zainstaluj MacPorts:"
    echo "    1. xcode-select --install"
    echo "    2. Pobierz instalator .pkg dla swojej wersji macOS:"
    echo "       https://www.macports.org/install.php"
    echo "    3. Otwórz nowy terminal i uruchom ponownie ./install.sh"
  fi
  echo ""
  exit 1
fi

if [ "$PM" = "brew" ] && ! $HAS_BREW; then err "Wymuszono --brew, ale Homebrew nie jest zainstalowany."; exit 1; fi
if [ "$PM" = "macports" ] && ! $HAS_PORT; then err "Wymuszono --macports, ale MacPorts nie jest zainstalowany."; exit 1; fi

if [ "$PM" = "brew" ]; then
  ok "Homebrew: $(brew --version | head -1)"
  if [ "$ARCH" = "x86_64" ]; then
    warn "Homebrew na Intelu jest w Tier 3 (brak nowych bottles, wsparcie do 09.2027)."
    warn "Zalecane: MacPorts → https://www.macports.org/install.php"
  fi
else
  ok "MacPorts: $(port version 2>/dev/null)"
  step "Instalacja przez MacPorts wymaga sudo — możesz zostać poproszony o hasło."
  sudo -v || { err "Brak uprawnień sudo."; exit 1; }
fi

# ── 2. Zależności ─────────────────────────────────────────────────────────────
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

port_install() {
  if port -q installed "$1" 2>/dev/null | grep -q "(active)"; then
    ok "$1 (już zainstalowany)"
  else
    step "sudo port install $1"
    sudo port -N install "$1" || { err "Nie udało się zainstalować $1"; exit 1; }
    ok "$1"
  fi
}

# Hack Nerd Font nie ma portu w MacPorts — pobieramy go z GitHuba do ~/Library/Fonts
font_install_manual() {
  local fonts_dir="$HOME/Library/Fonts"
  if ls "$fonts_dir"/HackNerdFont* &>/dev/null; then
    ok "Hack Nerd Font (już zainstalowany)"
    return
  fi
  step "Pobieram Hack Nerd Font z github.com/ryanoasis/nerd-fonts"
  local tmp; tmp="$(mktemp -d)"
  if curl -fsSL -o "$tmp/Hack.zip" \
       "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip" \
     && unzip -q -o "$tmp/Hack.zip" -d "$tmp/Hack"; then
    mkdir -p "$fonts_dir"
    cp "$tmp"/Hack/HackNerdFont-*.ttf "$fonts_dir"/
    ok "Hack Nerd Font → $fonts_dir"
  else
    err "Nie udało się pobrać czcionki — zainstaluj ręcznie: https://www.nerdfonts.com/font-downloads"
  fi
  rm -rf "$tmp"
}

PACKAGES=(fastfetch zsh-autosuggestions zsh-syntax-highlighting)

if [ "$PM" = "brew" ]; then
  for p in "${PACKAGES[@]}"; do brew_install "$p"; done
  brew_cask_install font-hack-nerd-font
else
  for p in "${PACKAGES[@]}"; do port_install "$p"; done
  font_install_manual
fi

# ── 3. Konfiguracja fastfetch ─────────────────────────────────────────────────
info "Konfiguruję fastfetch..."

FF_DIR="$HOME/.config/fastfetch"
mkdir -p "$FF_DIR"

cp "$SCRIPT_DIR/config.jsonc" "$FF_DIR/config.jsonc"
ok "config.jsonc → $FF_DIR/"

cp "$SCRIPT_DIR/launch.sh" "$FF_DIR/launch.sh"
chmod +x "$FF_DIR/launch.sh"
ok "launch.sh → $FF_DIR/ (chmod +x)"

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
echo -e "${BOLD}  Instalacja zakończona pomyślnie! (${PM})${NC}"
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
