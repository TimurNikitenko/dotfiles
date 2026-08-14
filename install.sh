#!/usr/bin/env bash
set -e  # прерывать при любой ошибке

# ===== Конфигурация =====
REPO_URL="https://github.com/TimurNikitenko/dotfiles.git"   # <-- замените на свой URL
DOTFILES_DIR="$HOME/dotfiles"
STOW_PACKAGES=("git" "nvim" "wezterm" "zsh")   # папки-пакеты в корне репозитория
# ========================

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Флаги (можно передать как аргументы)
FORCE=false
ADOPT=false
NO_INSTALL=false

usage() {
    echo "Использование: $0 [опции]"
    echo "  --repo URL       URL репозитория (по умолчанию: $REPO_URL)"
    echo "  --force          Принудительно удалять конфликтующие файлы (без подтверждения)"
    echo "  --adopt          Принять существующие файлы в репозиторий (заменяет содержимое репозитория)"
    echo "  --no-install     Не устанавливать зависимости (git, stow)"
    echo "  --help           Показать эту справку"
    exit 0
}

# Разбор аргументов
while [[ $# -gt 0 ]]; do
    case "$1" in
        --repo)
            REPO_URL="$2"
            shift 2
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --adopt)
            ADOPT=true
            shift
            ;;
        --no-install)
            NO_INSTALL=true
            shift
            ;;
        --help)
            usage
            ;;
        *)
            echo -e "${RED}Неизвестный аргумент: $1${NC}"
            usage
            ;;
    esac
done

echo -e "${GREEN}=== Dotfiles Installer ===${NC}"

# 1. Установка зависимостей (если не отключено)
if [ "$NO_INSTALL" = false ]; then
    echo -e "${YELLOW}Проверка и установка необходимых пакетов...${NC}"
    if command -v apt-get &>/dev/null; then
        sudo apt-get update
        sudo apt-get install -y git stow
    else
        echo -e "${RED}apt-get не найден. Установите вручную git и stow.${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}Пропускаем установку зависимостей (--no-install)${NC}"
fi

# 2. Клонирование или обновление репозитория
if [ -d "$DOTFILES_DIR/.git" ]; then
    echo -e "${YELLOW}Репозиторий уже существует. Обновляем...${NC}"
    cd "$DOTFILES_DIR"
    git pull
else
    if [ -e "$DOTFILES_DIR" ]; then
        echo -e "${RED}Каталог $DOTFILES_DIR существует, но не является git-репозиторием.${NC}"
        echo -e "Пожалуйста, удалите или переименуйте его и запустите скрипт заново."
        exit 1
    fi
    echo -e "${GREEN}Клонируем репозиторий...${NC}"
    git clone "$REPO_URL" "$DOTFILES_DIR"
    cd "$DOTFILES_DIR"
fi

# 3. Применение stow для каждого пакета
echo -e "${YELLOW}Применяем символические ссылки через stow...${NC}"

for package in "${STOW_PACKAGES[@]}"; do
    # Проверяем, существует ли папка пакета в репозитории
    if [ ! -d "$DOTFILES_DIR/$package" ]; then
        echo -e "${RED}Пакет '$package' не найден в репозитории. Пропускаем.${NC}"
        continue
    fi

    echo -e "  Обработка пакета: ${GREEN}$package${NC}"

    # Формируем опции stow
    STOW_OPTS="-v --no-folding --restow"

    if [ "$ADOPT" = true ]; then
        STOW_OPTS="$STOW_OPTS --adopt"
        echo -e "    ${YELLOW}Включён режим --adopt: существующие файлы будут скопированы в репозиторий.${NC}"
    fi

    if [ "$FORCE" = true ]; then
        # --override удаляет конфликтующие файлы (только если они не являются симлинками)
        STOW_OPTS="$STOW_OPTS --override=.*"
        echo -e "    ${YELLOW}Включён режим --force: конфликтующие файлы будут удалены.${NC}"
    fi

    # Выполняем stow
    if ! stow $STOW_OPTS "$package" 2>&1 | sed 's/^/    /'; then
        echo -e "    ${RED}Ошибка при применении stow для пакета $package.${NC}"
        echo -e "    Возможно, есть конфликтующие файлы. Попробуйте запустить с --force или --adopt."
        exit 1
    fi
done

echo -e "${GREEN}✅ Все конфиги развёрнуты успешно!${NC}"
echo -e "Теперь перезагрузите терминал или откройте новый WezTerm, чтобы изменения вступили в силу."
