#!/usr/bin/env bash
# ██████╗ ██╗  ██╗ █████╗ ███╗   ██╗██╗   ██╗███████╗██╗  ██╗
# ██╔══██╗██║  ██║██╔══██╗████╗  ██║██║   ██║██╔════╝██║  ██║
# ██║  ██║███████║███████║██╔██╗ ██║██║   ██║███████╗███████║
# ██║  ██║██╔══██║██╔══██║██║╚██╗██║██║   ██║╚════██║██╔══██║
# ██████╔╝██║  ██║██║  ██║██║ ╚████║╚██████╔╝███████║██║  ██║
# ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝
#
#   Author  - dhanush777x
#   Repo    - https://github.com/dhanush777x/dotfiles
#
#   RiceInstaller - Installs dhanush777x's bspwm dotfiles rice
#
# ================================================================

set -euo pipefail

# ================================================================
# COLORS & UI
# ================================================================
BOLD=$(tput bold   2>/dev/null || true)
RESET=$(tput sgr0  2>/dev/null || true)
RED=$(tput setaf 1 2>/dev/null || true)
YEL=$(tput setaf 3 2>/dev/null || true)
GRN=$(tput setaf 2 2>/dev/null || true)
BLU=$(tput setaf 4 2>/dev/null || true)

log()  { printf "%b\n" "${BOLD}${BLU}[INFO]${RESET}  $*"; }
ok()   { printf "%b\n" "${BOLD}${GRN}[ OK ]${RESET}  $*"; }
warn() { printf "%b\n" "${BOLD}${YEL}[WARN]${RESET}  $*"; }
err()  { printf "%b\n" "${BOLD}${RED}[ERR ]${RESET}  $*" >&2; }
die()  { err "$*"; exit 1; }

logo() {
    printf "%b" "
                                      
                                      
 Y5555555555555555555555YJ!^.         
.@@@@@@@@@@@@@@@@@@@@@@@@@@@@&5:      
                        ..^?B@@@&!    
             ...             .?@@#:   
           :&@@G                .     
          !@@@5                       
         J@@@7                   .JJ? 
        P@@@^                    ?@@@ 
      .#@@&.                     &@@G 
     :&@@B                      B@@&. 
    ~@@@Y                     7&@@#.  
   J@@@J                 .^?B@@@&!    
  G@@@@@@@@@@@@@@@&    :@@@@@&5^      
 ^5YYYYYYYYYYYYYYYJ    .5J7^.         
                                      
                                      
   ${BOLD}${RED}[ ${YEL}$1 ${RED}]${RESET}
"
}

# ================================================================
# CONFIG
# ================================================================
REPO_URL="https://github.com/dhanush777x/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"
BACKUP_ROOT="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
MISSING_PKGS_FILE="$HOME/missing_packages.txt"
PWRX_REPO="https://github.com/Dhanush-777x/pwrx.git"
SLIDEFX_REPO="https://github.com/Dhanush-777x/bspwm-slidefx.git"

# Populated during welcome() — consumed by install_packages()
USE_CHAOTIC_AUR="n"

# ================================================================
# FIX 1: Safe trap accumulator — never overwrites previous traps
# ================================================================
trap_add() {
    local new_cmd="$1"
    local existing
    existing=$(trap -p EXIT 2>/dev/null | awk -F"'" '{print $2}')
    if [[ -n "$existing" ]]; then
        trap "${new_cmd}; ${existing}" EXIT
    else
        trap "${new_cmd}" EXIT
    fi
}

# ================================================================
# FIX 2: Error trap — surface the exact line that killed the script
# ================================================================
trap 'err "Script failed at line ${LINENO} — command: ${BASH_COMMAND}"' ERR

# ================================================================
# INITIAL CHECKS
# ================================================================
initial_checks() {
    clear
    logo "Preflight Checks"

    # Must be Arch-based
    command -v pacman &>/dev/null || die "This installer supports Arch-based systems only."

    # Must NOT be root
    [ "$(id -u)" = 0 ] && die "Do not run this script as root. Run as your normal user."

    # FIX 3: Removed the overly-strict "must run from HOME" check.
    # Users can invoke the script from any directory, e.g.:
    #   bash ~/dotfiles/install.sh

    ok "All preflight checks passed"
    sleep 1
}

# ================================================================
# WELCOME — also collects one-time user preferences
# ================================================================
welcome() {
    clear
    logo "Welcome, $USER"

    printf "%b\n" "${BOLD}${GRN}This script will set up dhanush777x's bspwm rice. Here's what it does:${RESET}

  ${BOLD}${GRN}[${YEL}i${GRN}]${RESET} Optionally add Chaotic-AUR repository
  ${BOLD}${GRN}[${YEL}i${GRN}]${RESET} Ensure yay (AUR helper) is installed
  ${BOLD}${GRN}[${YEL}i${GRN}]${RESET} Install all required packages
  ${BOLD}${GRN}[${YEL}i${GRN}]${RESET} Install pwrx and bspwm-slidefx
  ${BOLD}${GRN}[${YEL}i${GRN}]${RESET} Clone dotfiles from ${BLU}github.com/dhanush777x/dotfiles${RESET}
  ${BOLD}${GRN}[${YEL}i${GRN}]${RESET} Backup any existing configs
  ${BOLD}${GRN}[${YEL}i${GRN}]${RESET} Deploy configs via symlinks
  ${BOLD}${GRN}[${YEL}i${GRN}]${RESET} Enable NetworkManager, Bluetooth, MPD services
  ${BOLD}${GRN}[${YEL}i${GRN}]${RESET} Change your default shell to Zsh

  ${BOLD}${RED}[!]${RESET} ${BOLD}${RED}Your existing configs will be backed up, not deleted${RESET}
  ${BOLD}${RED}[!]${RESET} ${BOLD}${RED}System packages will be upgraded as part of this process${RESET}
"

    # Confirm install
    while true; do
        printf "%b" "${BOLD}${GRN}Do you wish to continue?${RESET} [y/N]: "
        read -r yn
        case "$yn" in
            [Yy]) break ;;
            [Nn]|"")
                printf "\n%b\n" "${BOLD}${YEL}Installation cancelled. Goodbye!${RESET}"
                exit 0 ;;
            *) warn "Please type 'y' or 'n'" ;;
        esac
    done

    # FIX 4: Make Chaotic-AUR opt-in, not forced
    printf "\n"
    printf "%b\n" "${BOLD}Chaotic-AUR${RESET} provides pre-built AUR packages (faster installs)."
    printf "%b\n" "${YEL}Note:${RESET} Requires keyserver access. Skip if on a restricted network."
    while true; do
        printf "%b" "${BOLD}${GRN}Enable Chaotic-AUR?${RESET} [y/N]: "
        read -r yn
        case "$yn" in
            [Yy]) USE_CHAOTIC_AUR="y"; break ;;
            [Nn]|"") USE_CHAOTIC_AUR="n"; break ;;
            *) warn "Please type 'y' or 'n'" ;;
        esac
    done
}

# ================================================================
# ADD CHAOTIC-AUR REPOSITORY (only if user opted in)
# ================================================================
add_chaotic_repo() {
    if [[ "$USE_CHAOTIC_AUR" != "y" ]]; then
        log "Skipping Chaotic-AUR (user opted out)"
        return 0
    fi

    clear
    logo "Adding Chaotic-AUR Repository"
    sleep 1

    local repo_name="chaotic-aur"
    local key_id="3056513887B78AEB"

    log "Setting up Chaotic-AUR..."

    if ! pacman-key -f "$key_id" >/dev/null 2>&1; then
        log "Adding GPG key (trying multiple keyservers)..."
        # FIX 5: Fallback keyserver chain — primary often times out
        local key_added=0
        for ks in \
            "hkps://keyserver.ubuntu.com" \
            "hkps://keys.openpgp.org"     \
            "hkps://pgp.mit.edu"; do
            log "  Trying keyserver: $ks"
            if sudo pacman-key --recv-key "$key_id" --keyserver "$ks" 2>/dev/null; then
                key_added=1
                break
            fi
            warn "  Failed: $ks — trying next..."
        done
        if [[ $key_added -eq 0 ]]; then
            warn "Could not retrieve GPG key from any keyserver."
            warn "Chaotic-AUR will be skipped. You can add it manually later."
            USE_CHAOTIC_AUR="n"
            return 0
        fi
        sudo pacman-key --lsign-key "$key_id"
        ok "GPG key added and signed"
    else
        ok "GPG key already exists in keyring"
    fi

    log "Installing chaotic keyring and mirrorlist..."
    sudo pacman -U --noconfirm --needed \
        'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
    sudo pacman -U --noconfirm --needed \
        'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

    if ! grep -q "\[${repo_name}\]" /etc/pacman.conf; then
        printf "\n[%s]\nInclude = /etc/pacman.d/chaotic-mirrorlist\n" "$repo_name" \
            | sudo tee -a /etc/pacman.conf > /dev/null
        ok "Chaotic-AUR repository added to pacman.conf"
    else
        ok "Chaotic-AUR already configured in pacman.conf"
    fi

    sleep 2
}

# ================================================================
# ENSURE YAY
# ================================================================
ensure_yay() {
    clear
    logo "Setting Up AUR Helper"
    sleep 1

    if command -v yay &>/dev/null; then
        ok "yay is already installed"
        return 0
    fi

    log "Installing yay..."
    sudo pacman -S --needed --noconfirm git base-devel

    local tmpdir
    tmpdir=$(mktemp -d)
    # FIX 6: Use trap_add so this cleanup never clobbers other registered cleanups
    trap_add "rm -rf '${tmpdir}'"

    git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
    (cd "$tmpdir/yay" && makepkg -si --noconfirm)

    ok "yay installed successfully"
    sleep 2
}

# ================================================================
# SYSTEM UPDATE
# ================================================================
system_update() {
    clear
    logo "Updating System"
    sleep 1

    log "Running full system upgrade (this may take a while)..."
    yay -Syu --noconfirm
    ok "System is up to date"
    sleep 2
}

# ================================================================
# PACKAGE INSTALLER — with two-pass retry logic and structured log
# ================================================================
# install_pkgs_with_retry <source: pacman|yay> <pkg1> <pkg2> ...
install_pkgs_with_retry() {
    local source="$1"
    shift
    local pkgs=("$@")
    local failed=()
    local still_failed=()

    # ── First pass ────────────────────────────────────────────
    for pkg in "${pkgs[@]}"; do
        if [[ "$source" == "pacman" ]]; then
            sudo pacman -S --noconfirm --needed "$pkg" 2>/dev/null || failed+=("$pkg")
        else
            yay -S --noconfirm --needed "$pkg" 2>/dev/null || failed+=("$pkg")
        fi
    done

    # ── Retry pass ────────────────────────────────────────────
    if [[ ${#failed[@]} -gt 0 ]]; then
        warn "Retrying ${#failed[@]} failed package(s): ${failed[*]}"
        for pkg in "${failed[@]}"; do
            if [[ "$source" == "pacman" ]]; then
                sudo pacman -S --noconfirm --needed "$pkg" 2>/dev/null || still_failed+=("$pkg")
            else
                yay -S --noconfirm --needed "$pkg" 2>/dev/null || still_failed+=("$pkg")
            fi
        done
    fi

    # ── Report persistent failures ─────────────────────────────
    if [[ ${#still_failed[@]} -gt 0 ]]; then
        err "Packages not installed after 2 attempts (source: ${source}):"
        for pkg in "${still_failed[@]}"; do
            err "  - $pkg"
        done
        # FIX 7: Structured log line — easier to parse / review later
        {
            printf "[%s] source=%s packages=%s\n" \
                "$(date '+%Y-%m-%d %H:%M:%S')" "$source" "${still_failed[*]}"
        } >> "$MISSING_PKGS_FILE"
        warn "Failures logged to: $MISSING_PKGS_FILE"
    fi
}

# ================================================================
# INSTALL PACKAGES
# ================================================================
install_packages() {
    clear
    logo "Installing Packages"
    sleep 1

    # ── Official repository packages ──────────────────────────
    local pacman_pkgs=(
        # WM & Desktop
        bspwm sxhkd picom rofi dunst feh polybar
        lxsession xorg-xrandr xorg-xprop xorg-xkill
        xorg-xdpyinfo xorg-xsetroot xorg-xwininfo xorg-xrdb
        xdo xdotool xsettingsd xclip xdg-user-dirs

        # Terminals
        kitty alacritty

        # Fonts
        ttf-jetbrains-mono
        ttf-jetbrains-mono-nerd
        ttf-inconsolata
        ttf-terminus-nerd
        ttf-ubuntu-mono-nerd
        ttf-font-awesome
        ttf-material-design-icons
        ttf-meslo-nerd
        noto-fonts
        noto-fonts-emoji

        # System & Utilities
        base-devel git networkmanager bluez bluez-utils
        brightnessctl playerctl pamixer pulseaudio pavucontrol
        libinput-tools

        # CLI Tools
        tmux neovim yazi bat eza fzf maim imagemagick jq
        btop fastfetch ncmpcpp mpc mpd mpv cava
        pacman-contrib npm rustup redshift xcolor zoxide

        # File management
        thunar tumbler gvfs-mtp nautilus

        # Apps
        firefox geany

        # Icons & Themes
        papirus-icon-theme

        # Media
        libwebp webp-pixbuf-loader

        # Clipboard
        clipcat

        # Python
        python python-pip python-pipx python-gobject

        # Shell
        zsh zsh-autosuggestions zsh-history-substring-search zsh-syntax-highlighting

        # Misc
        jgmenu
    )
    # NOTE: brave-bin is AUR only — removed from pacman_pkgs entirely (FIX 8)

    # ── AUR packages ─────────────────────────────────────────
    local aur_pkgs=(
        brave-bin
        xwinwrap-0.9-bin
        i3lock-color
        simple-mtpfs
        fzf-tab-git
        bzmenu
        pyenv
        papirus-folders-catppuccin-git
    )

    # ── Chaotic-AUR exclusive packages ───────────────────────
    local chaotic_pkgs=(
        eww-git
    )

    log "Installing official repository packages..."
    install_pkgs_with_retry pacman "${pacman_pkgs[@]}"
    ok "Official packages done"

    log "Installing AUR packages..."
    # If Chaotic-AUR is active, eww-git will be pulled from there automatically;
    # if not, yay will still build it from source — either way, one list.
    install_pkgs_with_retry yay "${aur_pkgs[@]}" "${chaotic_pkgs[@]}"
    ok "AUR/Chaotic packages done"

    sleep 2
}

# ================================================================
# ENABLE SERVICES
# ================================================================
enable_services() {
    clear
    logo "Enabling Services"
    sleep 1

    log "Enabling NetworkManager..."
    sudo systemctl enable --now NetworkManager
    ok "NetworkManager enabled"

    log "Enabling Bluetooth..."
    sudo systemctl enable --now bluetooth
    ok "Bluetooth enabled"

    # MPD: disable system-level service to prevent conflicts
    if systemctl is-enabled --quiet mpd.service 2>/dev/null; then
        log "Disabling global MPD service..."
        sudo systemctl disable --now mpd.service
    fi

    # FIX 9: MPD user service is started AFTER dotfiles deploy in main().
    # Attempting it here would often fail (config not yet in place).
    log "MPD user service will be started after dotfiles are deployed."

    sleep 2
}

# ================================================================
# SETUP PIPX
# ================================================================
setup_pipx() {
    clear
    logo "Setting Up pipx"
    sleep 1

    if ! command -v pipx &>/dev/null; then
        log "Installing pipx via pip..."
        python -m pip install --user pipx --quiet
    fi

    log "Ensuring pipx path..."
    python -m pipx ensurepath

    # Make pipx-installed tools available in this session
    export PATH="$HOME/.local/bin:$PATH"

    # FIX 10: Warn user that a fresh shell is needed for the path to persist
    warn "pipx path configured. You may need to restart your shell for pipx apps to be available in future sessions."

    ok "pipx ready"
    sleep 1
}

# ================================================================
# INSTALL PWRX
# ================================================================
install_pwrx() {
    if command -v pwrx &>/dev/null; then
        ok "pwrx already installed, skipping"
        return 0
    fi

    log "Installing pwrx..."
    local tmpdir
    tmpdir=$(mktemp -d)
    # FIX 6 (continued): Use trap_add for safe cleanup accumulation
    trap_add "rm -rf '${tmpdir}'"

    git clone "$PWRX_REPO" "$tmpdir/pwrx"
    (cd "$tmpdir/pwrx" && pipx install .)
    ok "pwrx installed"
}

# ================================================================
# INSTALL BSPWM-SLIDEFX
# ================================================================
install_slidefx() {
    if command -v bspwm-slidefx &>/dev/null; then
        ok "bspwm-slidefx already installed, skipping"
        return 0
    fi

    log "Installing bspwm-slidefx..."

    command -v make &>/dev/null || sudo pacman -S --needed --noconfirm make

    local tmpdir
    tmpdir=$(mktemp -d)
    trap_add "rm -rf '${tmpdir}'"

    git clone "$SLIDEFX_REPO" "$tmpdir/bspwm-slidefx"
    (cd "$tmpdir/bspwm-slidefx" && make install)
    ok "bspwm-slidefx installed"
}

# ================================================================
# INSTALL CATPPUCCIN PAPIRUS ICONS
# ================================================================
install_catppuccin_papirus() {
    clear
    logo "Installing Catppuccin Papirus"
    sleep 1

    # Skip if already installed (idempotent)
    if find /usr/share/icons/Papirus-Dark -name "folder-cat-mocha-lavender.svg" -print -quit | grep -q .; then
        ok "Catppuccin Papirus already installed, skipping"
        return 0
    fi

    log "Cloning Catppuccin Papirus repo..."

    local tmpdir
    tmpdir=$(mktemp -d)
    trap_add "rm -rf '${tmpdir}'"

    if git clone --depth=1 https://github.com/catppuccin/papirus-folders.git "$tmpdir"; then
        log "Installing Catppuccin folder icons..."

        if sudo cp -r "$tmpdir/src/"* /usr/share/icons/Papirus-Dark/; then
            ok "Catppuccin Papirus icons installed"
        else
            warn "Failed to copy Catppuccin icons"
        fi
    else
        warn "Failed to clone Catppuccin Papirus repo"
    fi

    gtk-update-icon-cache /usr/share/icons/Papirus-Dark 2>/dev/null || true

    sleep 2
}

install_custom_tools() {
    clear
    logo "Installing Custom Tools"
    sleep 1

    setup_pipx
    install_pwrx
    install_slidefx

    sleep 2
}

# ================================================================
# CLONE DOTFILES
# ================================================================
clone_dotfiles() {
    clear
    logo "Cloning Dotfiles"
    sleep 1

    if [ -d "$DOTFILES_DIR" ]; then
        log "Dotfiles directory already exists — pulling latest changes..."
        (cd "$DOTFILES_DIR" && git pull)
        ok "Dotfiles updated"
    else
        log "Cloning from $REPO_URL ..."
        git clone --depth=1 "$REPO_URL" "$DOTFILES_DIR"
        ok "Dotfiles cloned to $DOTFILES_DIR"
    fi

    sleep 2
}

# ================================================================
# BACKUP EXISTING CONFIGS
# ================================================================
backup_existing_config() {
    clear
    logo "Backing Up Existing Configs"
    sleep 1

    # Ask about Neovim config
    local keep_nvim="y"
    printf "%b\n" "${BOLD}The rice ships with a Neovim config. If you have your own, you can keep it.${RESET}"
    while true; do
        printf "%b" "${BOLD}${YEL}Replace your existing Neovim config with the rice's?${RESET} [y/N]: "
        read -r yn
        case "$yn" in
            [Yy]) keep_nvim="y"; break ;;
            [Nn]|"") keep_nvim="n"; break ;;
            *) warn "Type 'y' or 'n'" ;;
        esac
    done
    REPLACE_NVIM="$keep_nvim"
    export REPLACE_NVIM

    mkdir -p "$BACKUP_ROOT"
    log "Backup directory: $BACKUP_ROOT"

    local cfg_dirs=(
        bspwm alacritty clipcat picom rofi eww sxhkd
        dunst kitty polybar geany gtk-3.0 ncmpcpp yazi
        zsh mpd paru
    )

    for cfg in "${cfg_dirs[@]}"; do
        local target="$CONFIG_DIR/$cfg"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            mv "$target" "$BACKUP_ROOT/"
            log "Backed up: ~/.config/$cfg"
        elif [ -L "$target" ]; then
            log "Skipping symlink: ~/.config/$cfg (already managed)"
        fi
    done

    if [ "$REPLACE_NVIM" = "y" ] && [ -e "$CONFIG_DIR/nvim" ] && [ ! -L "$CONFIG_DIR/nvim" ]; then
        mv "$CONFIG_DIR/nvim" "$BACKUP_ROOT/"
        log "Backed up: ~/.config/nvim"
    fi

    for f in ".zshrc" ".tmux.conf" ".gtkrc-2.0" ".icons"; do
        if [ -e "$HOME/$f" ] && [ ! -L "$HOME/$f" ]; then
            mv "$HOME/$f" "$BACKUP_ROOT/"
            log "Backed up: ~/$f"
        fi
    done

    ok "All existing configs backed up to: $BACKUP_ROOT"
    sleep 2
}

# ================================================================
# DEPLOY CONFIGS (symlinks)
# ================================================================
deploy_dotfiles() {
    clear
    logo "Deploying Dotfiles"
    sleep 1

    mkdir -p "$CONFIG_DIR"
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.local/share"

    local errors=0

    # Symlink everything in dotfiles/config/ → ~/.config/
    if [ -d "$DOTFILES_DIR/config" ]; then
        for app_dir in "$DOTFILES_DIR/config/"*/; do
            local app_name
            app_name="$(basename "$app_dir")"
            local target="$CONFIG_DIR/$app_name"

            if [ "$app_name" = "nvim" ] && [ "${REPLACE_NVIM:-y}" != "y" ]; then
                log "Skipping nvim (user opted to keep existing config)"
                continue
            fi

            if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$(readlink -f "$app_dir")" ]; then
                log "$app_name: already linked, skipping"
                continue
            fi

            if ln -sfn "$app_dir" "$target"; then
                ok "Linked: ~/.config/$app_name"
            else
                err "Failed to link: $app_name"
                (( errors++ )) || true
            fi
        done
    else
        warn "No config/ directory found in dotfiles — skipping .config symlinks"
    fi

    # Root dotfiles
    for f in ".zshrc" ".tmux.conf" ".gtkrc-2.0"; do
        if [ -f "$DOTFILES_DIR/$f" ]; then
            if ln -sfn "$DOTFILES_DIR/$f" "$HOME/$f"; then
                ok "Linked: ~/$f"
            else
                err "Failed to link: $f"
                (( errors++ )) || true
            fi
        fi
    done

    # .icons
    if [ -d "$DOTFILES_DIR/home/.icons" ]; then
        ln -sfn "$DOTFILES_DIR/home/.icons" "$HOME/.icons" && ok "Linked: ~/.icons"
    fi

    # Apply Catppuccin Papirus accent
    command -v papirus-folders &>/dev/null || warn "papirus-folders not installed"

    log "Applying Catppuccin Papirus (Mocha Lavender)..."

    if command -v papirus-folders &>/dev/null; then
        papirus-folders -C cat-mocha-lavender --theme Papirus-Dark \
            >/dev/null 2>&1 && ok "Papirus folders set to Catppuccin Lavender" \
            || warn "Failed to apply Catppuccin Papirus accent"
    else
        warn "papirus-folders not found — skipping icon accent setup"
    fi

    # Local bin scripts
    if [ -d "$DOTFILES_DIR/misc/bin" ]; then
        for bin_file in "$DOTFILES_DIR/misc/bin/"*; do
            local bin_name
            bin_name="$(basename "$bin_file")"
            ln -sfn "$bin_file" "$HOME/.local/bin/$bin_name" && ok "Linked: ~/.local/bin/$bin_name"
        done
    fi

    # Install GTK Themes
    if [ -d "$DOTFILES_DIR/config/themes" ]; then
        log "Installing themes to ~/.themes..."
        mkdir -p "$HOME/.themes"

        for theme in "$DOTFILES_DIR/config/themes/"*/; do
            theme_name="$(basename "$theme")"
            target="$HOME/.themes/$theme_name"

            if [ -d "$target" ]; then
                log "Theme exists, skipping: $theme_name"
                continue
            fi

            cp -r "$theme" "$target" && ok "Installed theme: $theme_name"
        done
    fi

    # Font cache
    log "Refreshing font cache..."
    fc-cache -r

    # XDG user directories
    if [ ! -e "$HOME/.config/user-dirs.dirs" ]; then
        log "Generating XDG user directories..."
        xdg-user-dirs-update
    fi

    # Slide animations setup
    if command -v bspwm-slidefx &>/dev/null; then
        log "Configuring slide animations..."
        bspwm-slidefx setup-picom --force 2>/dev/null \
            || warn "bspwm-slidefx setup failed — run manually after reboot"
    fi

    if [[ $errors -gt 0 ]]; then
        warn "$errors symlink(s) failed. Check output above."
    else
        ok "All dotfiles deployed successfully"
    fi

    # FIX 9 (resolved): Start MPD user service NOW that the config is in place
    log "Starting MPD user service..."
    systemctl --user enable --now mpd.service 2>/dev/null \
        || warn "MPD user service could not be started — it will auto-start on next login."

    sleep 2
}

# ================================================================
# CONFIGURE PICOM FOR VMs
# ================================================================
configure_picom_vm() {
    local picom_config="$CONFIG_DIR/bspwm/config/picom.conf"

    if systemd-detect-virt --quiet >/dev/null 2>&1; then
        warn "Virtual machine detected — adjusting Picom for software rendering"
        if [ -f "$picom_config" ]; then
            sed -i 's/backend = "glx"/backend = "xrender"/' "$picom_config"
            sed -i 's/vsync = true/vsync = false/'          "$picom_config"
            ok "Picom: switched to xrender backend, vsync disabled"
        else
            warn "Picom config not found at $picom_config — skipping VM adjustment"
        fi
    fi
}

# ================================================================
# CHANGE DEFAULT SHELL TO ZSH
# ================================================================
change_shell() {
    clear
    logo "Changing Default Shell"
    sleep 1

    local zsh_path
    zsh_path=$(command -v zsh 2>/dev/null || true)

    if [ -z "$zsh_path" ]; then
        warn "Zsh not found — cannot change shell. Install zsh and run: chsh -s \$(which zsh)"
        return 0
    fi

    if [ "$SHELL" = "$zsh_path" ]; then
        ok "Zsh is already your default shell"
    else
        log "Changing shell to Zsh ($zsh_path)..."
        # FIX 11: Inform clearly when chsh needs a password (common on some PAM configs)
        if chsh -s "$zsh_path"; then
            ok "Default shell changed to Zsh"
        else
            warn "Failed to change shell automatically."
            warn "Some systems require a password for chsh. Run manually:"
            warn "  chsh -s $zsh_path"
        fi
    fi

    sleep 2
}

# ================================================================
# FINAL PROMPT
# ================================================================
final_prompt() {
    clear
    logo "Installation Complete!"

    ok "Rice installed successfully!"
    printf "\n"

    if [ -f "$MISSING_PKGS_FILE" ]; then
        warn "Some packages failed to install. Review: $MISSING_PKGS_FILE"
    fi

    printf "%b\n" "${BOLD}Next steps:${RESET}
  1. Reboot your system
  2. Select bspwm as your session at the login screen
  3. Optional — setup pwrx sudo rules:
     ${BLU}sudo visudo -f /etc/sudoers.d/pwrx${RESET}

  ${BOLD}Backup location:${RESET} ${BLU}$BACKUP_ROOT${RESET}
"

    while true; do
        printf "%b" "${BOLD}${YEL}Reboot now?${RESET} [y/N]: "
        read -r yn
        case "$yn" in
            [Yy])
                printf "\n%b\n" "${BOLD}${GRN}Rebooting...${RESET}"
                sleep 1
                sudo reboot
                break ;;
            [Nn]|"")
                printf "\n%b\n" "${BOLD}${YEL}Remember to reboot soon for changes to take effect!${RESET}"
                break ;;
            *) warn "Type 'y' or 'n'" ;;
        esac
    done
}

# ================================================================
# MAIN
# ================================================================
main() {
    initial_checks
    welcome              # ← also collects Chaotic-AUR preference

    add_chaotic_repo     # respects USE_CHAOTIC_AUR flag
    ensure_yay
    system_update

    install_packages
    install_catppuccin_papirus
    enable_services      # MPD user service deferred to after dotfiles deploy
    install_custom_tools

    clone_dotfiles
    backup_existing_config
    deploy_dotfiles      # ← MPD user service started here
    configure_picom_vm

    change_shell
    final_prompt
}

main "$@"
