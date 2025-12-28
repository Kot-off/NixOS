#!/bin/bash
# Скрипт для управления обоями рабочего стола
# Автоматическая смена каждые 30 минут

IMAGES_DIR="/etc/nixos/assets/images"
CURRENT_WALLPAPER_FILE="$HOME/.config/current-wallpaper.jpg"
LOG_FILE="$HOME/.cache/wallpaper-changer.log"

# Создаем папки если не существуют
mkdir -p "$IMAGES_DIR"
mkdir -p "$(dirname "$CURRENT_WALLPAPER_FILE")"
mkdir -p "$(dirname "$LOG_FILE")"

# Функция для логирования
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    echo "$1"
}

# Функция установки обоев
set_wallpaper() {
    local wallpaper="$1"
    
    if [ ! -f "$wallpaper" ]; then
        log "Ошибка: файл не найден: $wallpaper"
        return 1
    fi
    
    log "Устанавливаю обои: $(basename "$wallpaper")"
    
    # Пробуем разные методы установки обоев
    local success=false
    
    # Метод 1: hyprpaper (для Hyprland)
    if command -v hyprctl &> /dev/null && pgrep -x hyprpaper > /dev/null; then
        hyprctl hyprpaper preload "$wallpaper" 2>/dev/null
        hyprctl hyprpaper wallpaper "eDP-1,$wallpaper" 2>/dev/null
        if [ $? -eq 0 ]; then
            log "Обои установлены через hyprpaper"
            success=true
        fi
    
    # Метод 2: swaybg
    elif command -v swaybg &> /dev/null; then
        # Убиваем старый swaybg
        pkill -x swaybg 2>/dev/null
        # Запускаем новый
        swaybg -i "$wallpaper" -m fill &
        if [ $? -eq 0 ]; then
            log "Обои установлены через swaybg"
            success=true
        fi
    
    # Метод 3: feh
    elif command -v feh &> /dev/null; then
        feh --bg-fill "$wallpaper" 2>/dev/null
        if [ $? -eq 0 ]; then
            log "Обои установлены через feh"
            success=true
        fi
    
    else
        log "Не найден ни один менеджер обоев!"
        return 1
    fi
    
    if [ "$success" = true ]; then
        # Сохраняем путь к текущим обоям
        echo "$wallpaper" > "$CURRENT_WALLPAPER_FILE"
        
        # Создаем симлинк для быстрого доступа
        ln -sf "$wallpaper" "$HOME/.config/current-wallpaper.jpg" 2>/dev/null
        
        log "Обои успешно установлены: $(basename "$wallpaper")"
        return 0
    else
        log "Не удалось установить обои"
        return 1
    fi
}

# Функция случайных обоев
random_wallpaper() {
    # Получаем список всех изображений
    local images=()
    
    # Ищем все поддерживаемые форматы
    for ext in jpg jpeg png bmp webp; do
        while IFS= read -r -d $'\0' file; do
            images+=("$file")
        done < <(find "$IMAGES_DIR" -type f -iname "*.$ext" -print0)
    done
    
    local num_images=${#images[@]}
    
    if [ $num_images -eq 0 ]; then
        log "В папке $IMAGES_DIR нет изображений!"
        log "Поместите обои в: $IMAGES_DIR/"
        return 1
    fi
    
    # Выбираем случайное изображение
    local random_index=$((RANDOM % num_images))
    local selected_wallpaper="${images[$random_index]}"
    
    set_wallpaper "$selected_wallpaper"
}

# Функция показа меню
show_menu() {
    clear
    echo "=== УПРАВЛЕНИЕ ОБОЯМИ ==="
    echo "Папка с обоями: $IMAGES_DIR"
    echo "Текущие обои: $(basename "$(cat "$CURRENT_WALLPAPER_FILE" 2>/dev/null || echo 'Не установлены')")"
    echo ""
    
    echo "Доступные обои:"
    echo ""
    
    local count=1
    local image_list=()
    
    # Собираем все изображения
    for ext in jpg jpeg png bmp webp; do
        for img in "$IMAGES_DIR"/*.$ext "$IMAGES_DIR"/*.${ext^^} 2>/dev/null; do
            if [ -f "$img" ]; then
                image_list+=("$img")
                printf "  %2d) %s\n" "$count" "$(basename "$img")"
                count=$((count + 1))
            fi
        done
    done
    
    if [ ${#image_list[@]} -eq 0 ]; then
        echo "  (папка пуста)"
    fi
    
    echo ""
    echo "Команды:"
    echo "  [номер]    - установить выбранные обои"
    echo "  random     - случайные обои"
    echo "  add [файл] - добавить новые обои"
    echo "  list       - показать список файлов"
    echo "  auto       - включить автосмену (30 мин)"
    echo "  stop       - выключить автосмену"
    echo "  status     - текущий статус"
    echo "  log        - показать лог"
    echo "  help       - эта справка"
    echo "  exit       - выход"
    echo ""
}

# Функция добавления новых обоев
add_wallpaper() {
    local source_file="$1"
    
    if [ ! -f "$source_file" ]; then
        log "Ошибка: файл не найден: $source_file"
        return 1
    fi
    
    local filename=$(basename "$source_file")
    local dest="$IMAGES_DIR/$filename"
    
    # Копируем файл
    cp "$source_file" "$dest"
    
    # Оптимизируем для HiDPI экрана (3120x2080)
    if command -v convert &> /dev/null; then
        log "Оптимизирую изображение для HiDPI экрана..."
        convert "$dest" -resize "3120x2080^" -gravity center -extent 3120x2080 -quality 90 "$dest.optimized"
        mv "$dest.optimized" "$dest"
    fi
    
    log "Обои добавлены: $filename"
    echo "Обои успешно добавлены: $filename"
}

# Функция управления автосменой
manage_autochanger() {
    case "$1" in
        start|auto)
            systemctl --user enable --now auto-wallpaper-timer 2>/dev/null
            if [ $? -eq 0 ]; then
                log "Автосмена обоев включена (каждые 30 минут)"
                echo "✅ Автосмена обоев включена"
            else
                log "Не удалось включить автосмену обоев"
                echo "⚠️  Запустите: systemctl --user enable --now auto-wallpaper-timer"
            fi
            ;;
        stop)
            systemctl --user disable --now auto-wallpaper-timer 2>/dev/null
            log "Автосмена обоев выключена"
            echo "✅ Автосмена обоев выключена"
            ;;
        status)
            if systemctl --user is-active auto-wallpaper-timer &>/dev/null; then
                echo "✅ Автосмена обоев: ВКЛЮЧЕНА"
                echo "   Смена каждые 30 минут"
            else
                echo "❌ Автосмена обоев: ВЫКЛЮЧЕНА"
            fi
            ;;
    esac
}

# Основная логика
if [ "$1" = "random" ]; then
    # Автоматический режим: случайные обои
    random_wallpaper
    exit $?
elif [ "$1" = "auto" ] || [ "$1" = "start" ] || [ "$1" = "stop" ] || [ "$1" = "status" ]; then
    # Управление автосменой
    manage_autochanger "$1"
    exit 0
elif [ "$1" = "add" ] && [ -n "$2" ]; then
    # Добавление новых обоев
    add_wallpaper "$2"
    exit $?
elif [ "$1" = "list" ]; then
    # Показать список файлов
    ls -la "$IMAGES_DIR"
    exit 0
elif [ "$1" = "log" ]; then
    # Показать лог
    if [ -f "$LOG_FILE" ]; then
        cat "$LOG_FILE"
    else
        echo "Лог файл не найден"
    fi
    exit 0
elif [ "$1" = "help" ]; then
    show_menu
    exit 0
elif [ -n "$1" ]; then
    # Установка конкретного номера
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        # Найдем файл по номеру
        local count=1
        local selected_file=""
        
        for ext in jpg jpeg png bmp webp; do
            for img in "$IMAGES_DIR"/*.$ext "$IMAGES_DIR"/*.${ext^^} 2>/dev/null; do
                if [ -f "$img" ]; then
                    if [ $count -eq $1 ]; then
                        selected_file="$img"
                        break 2
                    fi
                    count=$((count + 1))
                fi
            done
        done
        
        if [ -n "$selected_file" ]; then
            set_wallpaper "$selected_file"
        else
            echo "Неверный номер!"
        fi
        exit $?
    else
        echo "Неизвестная команда: $1"
        echo "Используйте: $0 [random|auto|stop|status|add файл|list|log|help]"
        exit 1
    fi
fi

# Интерактивный режим
while true; do
    show_menu
    read -p "Выберите действие: " choice
    
    case $choice in
        [0-9]*)
            # Установка по номеру
            local count=1
            local selected_file=""
            
            for ext in jpg jpeg png bmp webp; do
                for img in "$IMAGES_DIR"/*.$ext "$IMAGES_DIR"/*.${ext^^} 2>/dev/null; do
                    if [ -f "$img" ]; then
                        if [ $count -eq $choice ]; then
                            selected_file="$img"
                            break 2
                        fi
                        count=$((count + 1))
                    fi
                done
            done
            
            if [ -n "$selected_file" ]; then
                set_wallpaper "$selected_file"
            else
                echo "Неверный номер!"
            fi
            ;;
        
        random)
            random_wallpaper
            ;;
        
        auto|start)
            manage_autochanger "start"
            ;;
        
        stop)
            manage_autochanger "stop"
            ;;
        
        status)
            manage_autochanger "status"
            ;;
        
        add)
            read -p "Введите путь к файлу: " filepath
            add_wallpaper "$filepath"
            ;;
        
        list)
            ls -la "$IMAGES_DIR"
            ;;
        
        log)
            if [ -f "$LOG_FILE" ]; then
                cat "$LOG_FILE"
            else
                echo "Лог файл не найден"
            fi
            ;;
        
        help)
            show_menu
            ;;
        
        exit|quit)
            echo "Выход..."
            exit 0
            ;;
        
        *)
            echo "Неизвестная команда. Введите 'help' для справки."
            ;;
    esac
    
    echo ""
    read -p "Нажмите Enter чтобы продолжить..."
done