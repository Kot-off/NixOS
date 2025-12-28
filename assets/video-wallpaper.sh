#!/bin/bash
# Скрипт для анимированных обоев (mp4, webm, gif)

VIDEO_DIR="/etc/nixos/assets/videos"
CURRENT_VIDEO_FILE="$HOME/.config/current-video-wallpaper"
LOG_FILE="$HOME/.cache/video-wallpaper.log"

# Создаем папку для видео если не существует
mkdir -p "$VIDEO_DIR"
mkdir -p "$(dirname "$CURRENT_VIDEO_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    echo "$1"
}

# Функция установки видео-обоев
set_video_wallpaper() {
    local video_file="$1"
    
    if [ ! -f "$video_file" ]; then
        log "Ошибка: видео файл не найден: $video_file"
        return 1
    fi
    
    # Останавливаем предыдущие видео-обои
    stop_video_wallpaper
    
    log "Устанавливаю видео-обои: $(basename "$video_file")"
    
    # Запускаем MPV как фон
    # --no-audio - без звука
    # --loop-file - зациклить видео
    # --no-osc - скрыть элементы управления
    # --no-border - без рамки
    # --wid=0 - сделать фоном (работает в Hyprland)
    mpv --no-audio \
        --loop-file \
        --no-osc \
        --no-border \
        --wid=0 \
        --panscan=1.0 \
        "$video_file" &
    
    MPV_PID=$!
    
    if [ $? -eq 0 ] && [ -n "$MPV_PID" ]; then
        # Сохраняем PID и путь к видео
        echo "$MPV_PID" > "$CURRENT_VIDEO_FILE.pid"
        echo "$video_file" > "$CURRENT_VIDEO_FILE"
        
        log "Видео-обои успешно запущены (PID: $MPV_PID)"
        log "Файл: $(basename "$video_file")"
        
        # Оптимизация для ноутбука (экономия батареи)
        if command -v cpulimit &> /dev/null; then
            cpulimit -p "$MPV_PID" -l 10 &  # Ограничить CPU до 10%
        fi
        
        return 0
    else
        log "Не удалось запустить видео-обои"
        return 1
    fi
}

# Функция остановки видео-обоев
stop_video_wallpaper() {
    if [ -f "$CURRENT_VIDEO_FILE.pid" ]; then
        local pid=$(cat "$CURRENT_VIDEO_FILE.pid")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null
            sleep 1
            kill -9 "$pid" 2>/dev/null 2>&1
            log "Остановлены видео-обои (PID: $pid)"
        fi
        rm -f "$CURRENT_VIDEO_FILE.pid"
    fi
}

# Функция случайных видео-обоев
random_video_wallpaper() {
    # Получаем список всех видео файлов
    local videos=()
    
    # Ищем все поддерживаемые форматы
    for ext in mp4 webm mkv avi mov gif; do
        while IFS= read -r -d $'\0' file; do
            videos+=("$file")
        done < <(find "$VIDEO_DIR" -type f -iname "*.$ext" -print0)
    done
    
    local num_videos=${#videos[@]}
    
    if [ $num_videos -eq 0 ]; then
        log "В папке $VIDEO_DIR нет видео файлов!"
        log "Поддерживаемые форматы: mp4, webm, mkv, avi, mov, gif"
        return 1
    fi
    
    # Выбираем случайное видео
    local random_index=$((RANDOM % num_videos))
    local selected_video="${videos[$random_index]}"
    
    set_video_wallpaper "$selected_video"
}

# Функция показа меню
show_menu() {
    clear
    echo "=== УПРАВЛЕНИЕ ВИДЕО-ОБОЯМИ ==="
    echo "Папка с видео: $VIDEO_DIR"
    echo ""
    
    # Проверяем текущие видео-обои
    if [ -f "$CURRENT_VIDEO_FILE.pid" ]; then
        local pid=$(cat "$CURRENT_VIDEO_FILE.pid")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Статус: ✅ ВКЛЮЧЕНЫ"
            echo "Текущее видео: $(basename "$(cat "$CURRENT_VIDEO_FILE" 2>/dev/null)")"
        else
            echo "Статус: ❌ ВЫКЛЮЧЕНЫ"
        fi
    else
        echo "Статус: ❌ ВЫКЛЮЧЕНЫ"
    fi
    
    echo ""
    echo "Доступные видео:"
    echo ""
    
    local count=1
    local video_list=()
    
    # Собираем все видео файлы
    for ext in mp4 webm mkv avi mov gif; do
        for video in "$VIDEO_DIR"/*.$ext "$VIDEO_DIR"/*.${ext^^} 2>/dev/null; do
            if [ -f "$video" ]; then
                video_list+=("$video")
                # Показываем информацию о видео
                local duration=$(ffprobe -v error -show_entries format=duration \
                    -of default=noprint_wrappers=1:nokey=1 "$video" 2>/dev/null | cut -d. -f1)
                local size=$(du -h "$video" | cut -f1)
                
                if [ -n "$duration" ]; then
                    local min=$((duration / 60))
                    local sec=$((duration % 60))
                    printf "  %2d) %s (%02d:%02d, %s)\n" "$count" "$(basename "$video")" "$min" "$sec" "$size"
                else
                    printf "  %2d) %s (%s)\n" "$count" "$(basename "$video")" "$size"
                fi
                count=$((count + 1))
            fi
        done
    done
    
    if [ ${#video_list[@]} -eq 0 ]; then
        echo "  (папка пуста)"
        echo ""
        echo "Поддерживаемые форматы:"
        echo "  MP4, WebM, MKV, AVI, MOV, GIF"
        echo ""
        echo "Рекомендуется:"
        echo "  • MP4 с H.264 кодеком"
        echo "  • Разрешение 3120x2080 (ваш экран)"
        echo "  • Битрейт 5-10 Mbps для качества"
        echo "  • Без звука (или отключить в плеере)"
    fi
    
    echo ""
    echo "Команды:"
    echo "  [номер]    - установить выбранное видео"
    echo "  random     - случайные видео-обои"
    echo "  stop       - остановить видео-обои"
    echo "  add [файл] - добавить новое видео"
    echo "  optimize   - оптимизировать видео для обоев"
    echo "  list       - показать список видео"
    echo "  status     - текущий статус"
    echo "  log        - показать лог"
    echo "  help       - эта справка"
    echo "  exit       - выход"
    echo ""
}

# Функция добавления видео
add_video() {
    local source_file="$1"
    
    if [ ! -f "$source_file" ]; then
        log "Ошибка: файл не найден: $source_file"
        return 1
    fi
    
    local filename=$(basename "$source_file")
    local dest="$VIDEO_DIR/$filename"
    
    # Копируем файл
    cp "$source_file" "$dest"
    
    log "Видео добавлено: $filename"
    echo "✅ Видео добавлено: $filename"
    
    # Предлагаем оптимизировать
    echo ""
    read -p "Оптимизировать видео для обоев? (y/n): " optimize_choice
    if [[ "$optimize_choice" =~ ^[YyДд] ]]; then
        optimize_video "$dest"
    fi
}

# Функция оптимизации видео для обоев
optimize_video() {
    local video_file="$1"
    
    if [ ! -f "$video_file" ]; then
        echo "Файл не найден: $video_file"
        return 1
    fi
    
    if ! command -v ffmpeg &> /dev/null; then
        echo "Установите ffmpeg для оптимизации видео"
        return 1
    fi
    
    local filename=$(basename "$video_file")
    local optimized_file="${video_file%.*}_optimized.mp4"
    
    echo "🔧 Оптимизация видео: $filename"
    echo "Это может занять некоторое время..."
    
    # Оптимизация для обоев:
    # 1. Убираем звук
    # 2. Оптимальное разрешение для вашего экрана
    # 3. Хорошее качество с низким битрейтом
    # 4. H.264 кодек для совместимости
    
    ffmpeg -i "$video_file" \
        -an \                             # Без аудио
        -vf "scale=3120:2080:force_original_aspect_ratio=decrease,pad=3120:2080:(ow-iw)/2:(oh-ih)/2" \
        -c:v libx264 \                    # H.264 кодек
        -preset slow \                    # Качественное сжатие
        -crf 23 \                         # Качество (18-28, чем меньше тем лучше)
        -pix_fmt yuv420p \                # Совместимый формат пикселей
        -movflags +faststart \            # Для быстрого старта
        "$optimized_file"
    
    if [ $? -eq 0 ] && [ -f "$optimized_file" ]; then
        # Заменяем оригинальный файл
        mv "$optimized_file" "$video_file"
        echo "✅ Видео оптимизировано!"
        echo "   Разрешение: 3120x2080"
        echo "   Кодек: H.264"
        echo "   Аудио: отключено"
    else
        echo "❌ Ошибка при оптимизации"
        rm -f "$optimized_file" 2>/dev/null
    fi
}

# Основная логика
if [ "$1" = "random" ]; then
    random_video_wallpaper
    exit $?
elif [ "$1" = "stop" ]; then
    stop_video_wallpaper
    echo "✅ Видео-обои остановлены"
    exit 0
elif [ "$1" = "status" ]; then
    if [ -f "$CURRENT_VIDEO_FILE.pid" ]; then
        local pid=$(cat "$CURRENT_VIDEO_FILE.pid")
        if kill -0 "$pid" 2>/dev/null; then
            echo "✅ Видео-обои: ВКЛЮЧЕНЫ"
            echo "   Видео: $(basename "$(cat "$CURRENT_VIDEO_FILE")")"
            echo "   PID: $pid"
        else
            echo "❌ Видео-обои: ВЫКЛЮЧЕНЫ"
        fi
    else
        echo "❌ Видео-обои: ВЫКЛЮЧЕНЫ"
    fi
    exit 0
elif [ "$1" = "add" ] && [ -n "$2" ]; then
    add_video "$2"
    exit $?
elif [ "$1" = "optimize" ] && [ -n "$2" ]; then
    optimize_video "$2"
    exit $?
elif [ "$1" = "list" ]; then
    ls -la "$VIDEO_DIR"
    exit 0
elif [ "$1" = "log" ]; then
    if [ -f "$LOG_FILE" ]; then
        cat "$LOG_FILE"
    else
        echo "Лог файл не найден"
    fi
    exit 0
elif [ "$1" = "help" ]; then
    show_menu
    exit 0
elif [ -n "$1" ] && [[ "$1" =~ ^[0-9]+$ ]]; then
    # Установка по номеру
    local count=1
    local selected_video=""
    
    for ext in mp4 webm mkv avi mov gif; do
        for video in "$VIDEO_DIR"/*.$ext "$VIDEO_DIR"/*.${ext^^} 2>/dev/null; do
            if [ -f "$video" ]; then
                if [ $count -eq $1 ]; then
                    selected_video="$video"
                    break 2
                fi
                count=$((count + 1))
            fi
        done
    done
    
    if [ -n "$selected_video" ]; then
        set_video_wallpaper "$selected_video"
    else
        echo "Неверный номер!"
    fi
    exit $?
fi

# Интерактивный режим
while true; do
    show_menu
    read -p "Выберите действие: " choice
    
    case $choice in
        [0-9]*)
            local count=1
            local selected_video=""
            
            for ext in mp4 webm mkv avi mov gif; do
                for video in "$VIDEO_DIR"/*.$ext "$VIDEO_DIR"/*.${ext^^} 2>/dev/null; do
                    if [ -f "$video" ]; then
                        if [ $count -eq $choice ]; then
                            selected_video="$video"
                            break 2
                        fi
                        count=$((count + 1))
                    fi
                done
            done
            
            if [ -n "$selected_video" ]; then
                set_video_wallpaper "$selected_video"
            else
                echo "Неверный номер!"
            fi
            ;;
        
        random)
            random_video_wallpaper
            ;;
        
        stop)
            stop_video_wallpaper
            echo "✅ Видео-обои остановлены"
            ;;
        
        add)
            read -p "Введите путь к видео файлу: " filepath
            add_video "$filepath"
            ;;
        
        optimize)
            echo "Доступные видео для оптимизации:"
            ls -1 "$VIDEO_DIR"/*.{mp4,webm,mkv,avi,mov} 2>/dev/null | nl -w2 -s') '
            echo ""
            read -p "Введите номер видео для оптимизации: " video_num
            
            local count=1
            local selected_video=""
            
            for ext in mp4 webm mkv avi mov; do
                for video in "$VIDEO_DIR"/*.$ext 2>/dev/null; do
                    if [ -f "$video" ]; then
                        if [ $count -eq $video_num ]; then
                            selected_video="$video"
                            break 2
                        fi
                        count=$((count + 1))
                    fi
                done
            done
            
            if [ -n "$selected_video" ]; then
                optimize_video "$selected_video"
            else
                echo "Неверный номер!"
            fi
            ;;
        
        list)
            ls -la "$VIDEO_DIR"
            ;;
        
        status)
            if [ -f "$CURRENT_VIDEO_FILE.pid" ]; then
                local pid=$(cat "$CURRENT_VIDEO_FILE.pid")
                if kill -0 "$pid" 2>/dev/null; then
                    echo "✅ Видео-обои: ВКЛЮЧЕНЫ"
                    echo "   Видео: $(basename "$(cat "$CURRENT_VIDEO_FILE")")"
                else
                    echo "❌ Видео-обои: ВЫКЛЮЧЕНЫ"
                fi
            else
                echo "❌ Видео-обои: ВЫКЛЮЧЕНЫ"
            fi
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
            stop_video_wallpaper
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