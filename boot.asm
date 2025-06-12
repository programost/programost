bits 16
org 0x7C00

start:
    ; Инициализация сегментов и стека
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Сохранение номера диска
    mov [boot_drive], dl

    ; Очистка экрана
    mov ax, 0x0003
    int 0x10
  
main_menu:
    ; Вывод меню
    mov si, msg_menu
    call print_string

    ; Чтение команды
    mov di, cmd_buffer
    call read_cmd

    ; Обработка команды
    mov si, cmd_buffer
    cmp byte [si], '1'
    je load_kernel
    cmp byte [si], '2'
    je power_off
    cmp byte [si], '3'
    je test_vga
    
    ; Неверная команда
    mov si, msg_invalid
    call print_string
    jmp main_menu

load_kernel:
    ; Чтение 4 секторов (ядро) в 0x8000
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov [boot_drive], dl  ; Сохраняем номер диска

    ; Загрузка ядра с диска
    mov bx, KERNEL_OFFSET
    mov dh, 20          ; Читаем 20 секторов (10KB)
    mov dl, [boot_drive]
    call disk_load

    ; Переход к ядру
    jmp 0x0000:KERNEL_OFFSET

disk_load:
    push dx
    mov ah, 0x02        ; Функция чтения диска
    mov al, dh          ; Количество секторов
    mov ch, 0x00        ; Цилиндр 0
    mov dh, 0x00        ; Головка 0
    mov cl, 0x02        ; Сектор 2 (после загрузчика)
    int 0x13
    jc .error           ; Ошибка если CF=1
    pop dx
    cmp al, dh          ; Проверка количества прочитанных секторов
    jne .error
    ret
.error:
    mov si, disk_err_msg
    call print_string
    jmp $

power_off:
    ; Выключение через APM
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15
    
    ; Выключение через порты (для эмуляторов)
    mov dx, 0x604
    mov ax, 0x2000
    out dx, ax
    mov dx, 0xB004
    mov ax, 0x2000
    out dx, ax
    jmp $

test_vga:
    ; Установка текстового режима
    mov ax, 0x0003
    int 0x10
    
    mov ax, 0xB800
    mov es, ax
    mov cx, 5           ; 5 итераций (5 секунд)
    mov bl, 1           ; Начальный цвет фона

.next_color:
    ; Установка нового цвета фона
    mov al, bl
    shl al, 4           ; Сдвиг цвета в позицию фона
    xor di, di
    mov dx, 2000        ; Количество символов на экране

.update_screen:
    mov ah, [es:di+1]   ; Чтение атрибута
    and ah, 0x0F        ; Сохранение текста
    or ah, al            ; Установка нового фона
    mov [es:di+1], ah
    add di, 2
    dec dx
    jnz .update_screen

    ; Задержка 1 секунда
    call wait_1_sec
    
    ; Следующий цвет (цикл через 8 цветов)
    inc bl
    and bl, 0x07
    loop .next_color
    
    ; Возврат в меню
    jmp main_menu

; ================================================
; Вспомогательные функции
; ================================================

wait_1_sec:
    ; Ожидание 18 тиков (≈1 секунда)
    pusha
    xor ah, ah
    int 0x1A
    mov bx, dx
.add_wait:
    int 0x1A
    sub dx, bx
    cmp dx, 18
    jb .add_wait
    popa
    ret

print_string:
    ; Вывод строки (DS:SI)
    pusha
    mov ah, 0x0E
    mov bh, 0
.print_loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .print_loop
.done:
    popa
    ret

read_cmd:
    ; Чтение команды в буфер DI
    pusha
    mov cx, 0           ; Счетчик символов
    
.keyloop:
    ; Ожидание клавиши
    xor ah, ah
    int 0x16
    
    ; Обработка Enter
    cmp al, 0x0D
    je .done
    
    ; Обработка Backspace
    cmp al, 0x08
    je .backspace
    
    ; Проверка размера буфера
    cmp cx, 32
    jae .keyloop
    
    ; Сохранение символа
    stosb
    inc cx
    
    ; Отображение символа
    mov ah, 0x0E
    int 0x10
    jmp .keyloop

.backspace:
    ; Удаление символа
    test cx, cx
    jz .keyloop
    dec di
    dec cx
    
    ; Удаление на экране
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp .keyloop

.done:
    ; Завершение строки
    xor al, al
    stosb
    
    ; Перевод строки
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    
    popa
    ret

disk_error:
    ; Обработка ошибки диска
    mov si, msg_error
    call print_string
    jmp main_menu

; ================================================
; Данные
; ================================================
boot_drive: db 0
cmd_buffer: times 33 db 0

msg_menu:   db "Bootloader Menu:", 0x0D, 0x0A
            db "1 - Load Kernel ", 0x0D, 0x0A
            db "2 - Power Off Computer", 0x0D, 0x0A
            db "3 - Test VGA Colors", 0x0D, 0x0A
            db "Enter command: ", 0
            
msg_loading: db 0x0D, 0x0A, "Loading Kernel", 0x0D, 0x0A, 0
msg_invalid: db 0x0D, 0x0A, "Error: command", 0x0D, 0x0A, 0
msg_error:  db 0x0D, 0x0A, "hda read error", 0x0D, 0x0A, 0
disk_err_msg db "hda error", 0
KERNEL_OFFSET equ 0x1000


; Завершающий код загрузчика
times 510 - ($-$$) db 0
dw 0xAA55
