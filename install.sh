#!/usr/bin/env bash
set -e

# ===== Конфигурация =====
REPO_URL="https://github.com/TimurNikitenko/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
STOW_PACKAGES=("git" "nvim" "wezterm" "zsh")

# Флаги (по умолчанию всё включено)
INSTALL_PROGRAMS=true
CHANGE_SHELL=true
STOW_DOTFILES=true
FORCE=false
ADOPT=false
# ========================

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

usage() {
    cat <<EOF
Использование: $0 [опции]

Опции:
  --no-install       Не устанавливать пакеты (только stow)
  --no-shell         Не менять оболочку на Zsh
  --no-stow          Не применять stow (только установка)
  --force            Удалять конфликтующие файлы при stow
  --adopt            Принять существующие файлы в репозиторий
  --repo URL         URL репозитория (по умолчанию: $REPO_URL)
  --help             Показать эту справку

По умолчанию скрипт устанавливает пакеты, меняет оболочку и применяет stow.
EOF
    exit 0
}

# Разбор аргументов
while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-install) INSTALL_PROGRAMS=false; shift ;;
        --no-shell) CHANGE_SHELL=false; shift ;;
        --no-stow) STOW_DOTFILES=false; shift ;;
        --force) FORCE=true; shift ;;
        --adopt) ADOPT=true; shift ;;
        --repo) REPO_URL="$2"; shift 2 ;;
        --help) usage ;;
        *) echo -e "${RED}Неизвестный аргумент: $1${NC}"; usage ;;
    esac
done

echo -e "${GREEN}=== Dotfiles Installer (Universal) ===${NC}"

# ---- Определение ОС и пакетного менеджера ----
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    else
        OS=$(uname -s)
    fi
    echo -e "Обнаружена ОС: ${GREEN}$OS${NC}"
}

detect_package_manager() {
    if command -v apt-get &>/dev/null; then
        PKG_MANAGER="apt"
        INSTALL_CMD="sudo apt-get install -y"
        UPDATE_CMD="sudo apt-get update"
        PKG_LIST="git stow zsh neovim"
        # WezTerm может быть в репозитории, но часто нет – добавляем отдельную установку
        WEZTERM_INSTALL="wezterm" # если доступен
    elif command -v pacman &>/dev/null; then
        PKG_MANAGER="pacman"
        INSTALL_CMD="sudo pacman -S --needed"
        UPDATE_CMD="sudo pacman -Sy"
        PKG_LIST="git stow zsh neovim"
        WEZTERM_INSTALL="wezterm" # в официальных репозиториях Arch есть
    elif command -v dnf &>/dev/null; then
        PKG_MANAGER="dnf"
        INSTALL_CMD="sudo dnf install -y"
        UPDATE_CMD="sudo dnf check-update"
        PKG_LIST="git stow zsh neovim"
        WEZTERM_INSTALL="wezterm" # обычно есть в EPEL или RPMfusion
    elif command -v zypper &>/dev/null; then
        PKG_MANAGER="zypper"
        INSTALL_CMD="sudo zypper install -y"
        UPDATE_CMD="sudo zypper refresh"
        PKG_LIST="git stow zsh neovim"
        WEZTERM_INSTALL="wezterm"
    elif command -v brew &>/dev/null; then
        PKG_MANAGER="brew"
        INSTALL_CMD="brew install"
        UPDATE_CMD="brew update"
        PKG_LIST="git stow zsh neovim"
        WEZTERM_INSTALL="wezterm"
    else
        echo -e "${RED}Не найден поддерживаемый пакетный менеджер.${NC}"
        echo "Установите вручную: git, stow, zsh, neovim, wezterm"
        exit 1
    fi
    echo -e "Пакетный менеджер: ${GREEN}$PKG_MANAGER${NC}"
}

# ---- Установка пакетов ----
install_packages() {
    if [ "$INSTALL_PROGRAMS" = false ]; then
        echo -e "${YELLOW}Пропускаем установку пакетов (--no-install)${NC}"
        return
    fi

    echo -e "${YELLOW}Установка базовых пакетов...${NC}"
    $UPDATE_CMD || true
    $INSTALL_CMD $PKG_LIST

    # Установка WezTerm (если не установлен)
    if ! command -v wezterm &>/dev/null; then
        echo -e "${YELLOW}Установка WezTerm...${NC}"
        case $PKG_MANAGER in
            apt)
                # Для Ubuntu/Debian – скачиваем .deb с GitHub
                WEZTERM_URL=$(curl -s https://api.github.com/repos/wez/wezterm/releases/latest | grep "browser_download_url.*deb" | cut -d '"' -f 4)
                if [ -n "$WEZTERM_URL" ]; then
                    wget -O /tmp/wezterm.deb "$WEZTERM_URL"
                    sudo dpkg -i /tmp/wezterm.deb || sudo apt-get install -f -y
                else
                    echo -e "${RED}Не удалось найти .deb для WezTerm. Установите вручную.${NC}"
                fi
                ;;
            pacman)
                sudo pacman -S --needed wezterm
                ;;
            dnf)
                sudo dnf install -y wezterm || echo -e "${RED}WezTerm не найден в репозиториях. Установите вручную.${NC}"
                ;;
            zypper)
                sudo zypper install -y wezterm || echo -e "${RED}WezTerm не найден. Установите вручную.${NC}"
                ;;
            brew)
                brew install --cask wezterm
                ;;
            *)
                echo -e "${RED}Неизвестный менеджер для WezTerm. Установите вручную.${NC}"
                ;;
        esac
    else
        echo -e "${GREEN}WezTerm уже установлен.${NC}"
    fi
}

# ---- Клонирование/обновление репозитория ----
prepare_repo() {
    echo -e "${YELLOW}Подготовка репозитория dotfiles...${NC}"
    if [ -d "$DOTFILES_DIR/.git" ]; then
        cd "$DOTFILES_DIR"
        git pull
    else
        if [ -e "$DOTFILES_DIR" ]; then
            echo -e "${RED}Каталог $DOTFILES_DIR существует, но не является git-репозиторием.${NC}"
            exit 1
        fi
        git clone "$REPO_URL" "$DOTFILES_DIR"
        cd "$DOTFILES_DIR"
    fi
}

# ---- Применение stow ----
apply_stow() {
    if [ "$STOW_DOTFILES" = false ]; then
        echo -e "${YELLOW}Пропускаем применение stow (--no-stow)${NC}"
        return
    fi

    echo -e "${YELLOW}Применяем символические ссылки через stow...${NC}"
    for package in "${STOW_PACKAGES[@]}"; do
        if [ ! -d "$package" ]; then
            echo -e "${RED}Пакет '$package' не найден. Пропускаем.${NC}"
            continue
        fi
        echo -e "  Обработка: ${GREEN}$package${NC}"
        STOW_OPTS="-v --no-folding --restow"
        [ "$FORCE" = true ] && STOW_OPTS="$STOW_OPTS --override=.*"
        [ "$ADOPT" = true ] && STOW_OPTS="$STOW_OPTS --adopt"
        if ! stow $STOW_OPTS "$package" 2>&1 | sed 's/^/    /'; then
            echo -e "    ${RED}Ошибка. Попробуйте --force или --adopt.${NC}"
            exit 1
        fi
    done
}

# ---- Смена оболочки на Zsh ----
change_shell() {
    if [ "$CHANGE_SHELL" = false ]; then
        echo -e "${YELLOW}Пропускаем смену оболочки (--no-shell)${NC}"
        return
    fi

    if command -v zsh &>/dev/null; then
        if [ "$SHELL" != "$(which zsh)" ]; then
            echo -e "${YELLOW}Меняем оболочку по умолчанию на Zsh...${NC}"
            chsh -s "$(which zsh)" || echo -e "${RED}Не удалось сменить оболочку. Сделайте это вручную: chsh -s $(which zsh)${NC}"
        else
            echo -e "${GREEN}Zsh уже является оболочкой по умолчанию.${NC}"
        fi
    else
        echo -e "${RED}Zsh не установлен. Пропускаем смену оболочки.${NC}"
    fi
}

# ---- Главная функция ----
main() {
    detect_os
    detect_package_manager
    install_packages
    prepare_repo
    apply_stow
    change_shell
    echo -e "${GREEN}✅ Всё готово! Перезагрузите терминал или откройте новый WezTerm.${NC}"
}

main
