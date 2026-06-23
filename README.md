# better-macos-terminal

macOS terminal setup with a JJK theme — custom zsh prompt, fastfetch with ASCII Apple logo and a two-section specs layout.

![Preview](assets/preview.png)

## Prerequisites

- **macOS** with the default **Terminal.app**
- **Homebrew** — https://brew.sh (the installer will check for it)
- **Nerd Font set manually** in Terminal.app after installation:
  `Terminal → Settings → Profiles → Font → Hack Nerd Font`

## Installation

```bash
git clone https://github.com/dominikx2002/better-macos-terminal.git
cd better-macos-terminal
./install.sh
```

The script handles everything automatically:

1. Checks for Homebrew (exits with a message if missing)
2. Installs via brew: `fastfetch`, `chafa`, `imagemagick`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `font-hack-nerd-font`
3. Copies `config.jsonc` and `launch.sh` to `~/.config/fastfetch/`
4. **Backs up** your current `~/.zshrc` → `~/.zshrc.backup.YYYYMMDDHHMMSS` (never overwrites without a backup)
5. Creates a symlink `~/.zshrc → <repo>/dotfiles/zshrc`

After installation run `source ~/.zshrc` or open a new terminal.

> **Safe to re-run** — running `./install.sh` again skips already-installed packages and refreshes the symlink without creating unnecessary backups.

## Autostart

Fastfetch launches automatically on every new terminal session — via a block at the end of `dotfiles/zshrc` that calls `~/.config/fastfetch/launch.sh` only when the shell is interactive and attached to a TTY (does not run inside scripts or pipes).

## Repo structure

```
config.jsonc          — fastfetch configuration
launch.sh             — script that runs fetch (copied to ~/.config/fastfetch/)
dotfiles/
  zshrc               — zsh configuration (symlinked as ~/.zshrc)
images/               — optional custom logo images
install.sh            — installer
```

---

## Polski / Polish

Konfiguracja terminala macOS z motywem JJK — niestandardowy prompt zsh, fastfetch z ASCII logo Apple i dwusekcyjnym layoutem specyfikacji.

### Wymagania wstępne

- **macOS** z domyślnym **Terminal.app**
- **Homebrew** — https://brew.sh (instalator sprawdzi jego obecność)
- **Nerd Font ustawiony ręcznie** w Terminal.app po instalacji:
  `Terminal → Ustawienia → Profile → Czcionka → Hack Nerd Font`

### Instalacja

```bash
git clone https://github.com/dominikx2002/better-macos-terminal.git
cd better-macos-terminal
./install.sh
```

Skrypt zrobi wszystko automatycznie:

1. Sprawdza Homebrew (przerwie z komunikatem jeśli brak)
2. Instaluje przez brew: `fastfetch`, `chafa`, `imagemagick`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `font-hack-nerd-font`
3. Kopiuje `config.jsonc` i `launch.sh` do `~/.config/fastfetch/`
4. **Robi kopię zapasową** aktualnego `~/.zshrc` → `~/.zshrc.backup.YYYYMMDDHHMMSS` (nigdy nie nadpisuje bez backupu)
5. Tworzy symlink `~/.zshrc → <repo>/dotfiles/zshrc`

Po instalacji uruchom `source ~/.zshrc` lub otwórz nowy terminal.

> **Bezpieczne do wielokrotnego uruchomienia** — ponowne `./install.sh` pomija już zainstalowane pakiety i odświeża symlink bez zbędnych backupów.

### Autostart

Fastfetch uruchamia się automatycznie przy każdym otwarciu nowego terminala — dzięki blokowi na końcu `dotfiles/zshrc`, który wywołuje `~/.config/fastfetch/launch.sh` tylko gdy powłoka jest interaktywna i podłączona do TTY (nie odpala się w skryptach ani pipe'ach).

### Struktura repo

```
config.jsonc          — konfiguracja fastfetch
launch.sh             — skrypt uruchamiający fetch (kopiowany do ~/.config/fastfetch/)
dotfiles/
  zshrc               — konfiguracja zsh (symlinked jako ~/.zshrc)
images/               — opcjonalne własne obrazy logo
install.sh            — instalator
```
