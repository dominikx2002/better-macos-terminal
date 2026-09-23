🇬🇧 English | [🇵🇱 Polski](README.pl.md)

# better-macos-terminal

macOS terminal setup with a JJK theme — custom zsh prompt, fastfetch with ASCII Apple logo and a two-section specs layout.

![Preview](assets/preview.png)

## Prerequisites

- **macOS** with the default **Terminal.app**
- **A package manager** — the installer picks one automatically:
  - **Intel Mac → [MacPorts](https://www.macports.org/install.php)** (recommended). Since Homebrew 7.0 Intel is Tier 3: no new bottles, support ends in September 2027. Install `xcode-select --install`, then the `.pkg` for your macOS version (e.g. *Sequoia*).
  - **Apple Silicon → [Homebrew](https://brew.sh)**
- **Nerd Font set manually** in Terminal.app after installation:
  `Terminal → Settings → Profiles → Font → Hack Nerd Font`

## Installation

```bash
git clone https://github.com/dominikx2002/better-macos-terminal.git
cd better-macos-terminal
./install.sh              # auto-detect
./install.sh --macports   # force MacPorts
./install.sh --brew       # force Homebrew
```

The script handles everything automatically:

1. Detects the package manager: Homebrew on Apple Silicon, MacPorts otherwise (exits with instructions if neither is installed)
2. Installs `fastfetch`, `zsh-autosuggestions`, `zsh-syntax-highlighting` and **Hack Nerd Font** (Homebrew cask, or downloaded from [nerd-fonts](https://github.com/ryanoasis/nerd-fonts) into `~/Library/Fonts` when using MacPorts — MacPorts will ask for your `sudo` password)
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
install.sh            — installer
```
