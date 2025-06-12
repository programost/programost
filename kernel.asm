[org 0x1000]
[bits 16]

jmp kernel_main

; Структура файла
file_size equ 16 + 256
struc file
    .name: resb 16
    .content: resb 256
endstruc

; Данные ядра
welcome_msg db "YodaOS v1.2", 13, 10, 0
prompt db "YodaOS-tool> ",0 
newline db 13, 10, 0
unknown_cmd db "Unknown command", 13, 10, 0
help_msg db "Commands: help, shutdown, reboot, neofetch, yred, file, list, run", 13, 10, 0
file_not_found db "File not found", 13, 10, 0
file_prompt db "Enter filename: ", 0
editing_msg db "Editing (ESC=save, BACKSPACE=delete):", 13, 10, 0
file_saved_msg db "File saved!", 13, 10, 0
list_header db "Files in system:", 13, 10, 0
list_empty db "No files found", 13, 10, 0
list_entry db " - ", 0
run_prompt db "Enter script name: ", 0
script_error db "Script error at line ", 0
script_end_msg db "Script finished", 13, 10, 0
press_any_key db "Press any key...", 13, 10, 0
unknown_script_cmd db "Unknown command: ", 0
input_prompt db "Input: ", 0
var_not_found db "Variable not found: ", 0
if_true_msg db "Condition true", 13, 10, 0
if_false_msg db "Condition false", 13, 10, 0
error_disk db "Error code 1: read file system imposible", 13, 10, 0
process_msg db "1. System | 0% cpu | 20 KB ram |", 13, 10, 0
neofetch_msg:
    db "  @@@@@@@  ", 0x0D, 0x0A   
    db " @@&&&&&@@ ", 0x0D, 0x0A 
    db "@##%   %##@", 0x0D, 0x0A 
    db "@##*   *##@", 0x0D, 0x0A   
    db "@##%   %##@", 0x0D, 0x0A
    db " @@&&&&&@@ ", 0x0D, 0x0A  
    db "  @@@@@@@  ", 0x0D, 0x0A 
    db "RAM: ???MB",0x0D, 0x0A
    db "VIDEO MEMORY: ???MB",0x0D, 0x0A
    db "system: YodaOS console edition v1.2 ",0x0D, 0x0A
    db "kernel: YodaOS v1.0.0.1-x86_64",0x0D, 0x0A
    db "z-ram: none",0x0D, 0x0A
    db "processor: Unknown",0x0D, 0x0A
    db "disk: None",0x0D, 0x0A
    db "shell: YodaOS bsm-1.0",0x0D, 0x0A, 0
logcat_msg:
    db "starting system, bootloader", 13, 10
    db "boot - good", 13, 10
    db "boot - starting kernel..", 13, 10
    db "boot - kernel has starting", 13, 10
    db "boot - kernel", 13, 10
    db "kernel - starting system..", 13, 10
    db "kernel - load variable", 13, 10
    db "kernel - load file system", 13, 10
    db "kernel - good, system has starting", 13, 10
    db "kernel - log exit", 13, 10, 0
info_myl_msg:
    db "This MYL script language in YodaOS", 13, 10
    db "create by Yoda", 13, 10, 0
learn_myl_msg:
    db "learn MYL language, lets start)", 13, 10, 0
    db "PRINT <var or text> - print text or var on screen"
    db "SET <var> 0 - set value <var> 0"
    db "INPUT <var> - enter value in var"
    db "CLEAR - clear you screen"
    db "WAIT - wait you type on keyboard"
    db "IF <var> <operator> <other var or number> <action> <func> - check var > var2, var < var2, var = var2.  "
    db "IF operators:"
    db "EQ - var1 = var2"
    db "GT - var1 > var2"
    db "SYSCALL - call system command example SYSCALL neofetch"
    db "GOTO <cycle name> - infinity cycle, example code:"
    db "GOTO label"
    db "PRINT test code"
    db ":label"
    db "EXIT"
    db "EXIT - end script file"
sb_msg db "sb version: 1.0", 13, 10 , 0

; Буферы
current_file: times 16 db 0
command_buffer: times 64 db 0
file_buffer: times 256 db 0
line_buffer: times 80 db 0
input_buffer: times 64 db 0
var_name_buffer: times 16 db 0
var_value_buffer: times 16 db 0

; Переменные (максимум 26 - A-Z)
variables:
var_A dw 0
var_B dw 0
var_C dw 0
var_D dw 0
var_E dw 0
var_F dw 0
var_G dw 0
var_H dw 0
var_I dw 0
var_J dw 0
var_K dw 0
var_L dw 0
var_M dw 0
var_N dw 0
var_O dw 0
var_P dw 0
var_Q dw 0
var_R dw 0
var_S dw 0
var_T dw 0
var_U dw 0
var_V dw 0
var_W dw 0
var_X dw 0
var_Y dw 0
var_Z dw 0

; Файловая система (5 файлов)
files:
    istruc file
        at file.name, db "help.myl",0
        at file.content, db "PRINT Help programm of MYL lang type 1, 2, 3", 13, 10
                        db "INPUT A", 13, 10
                        db "IF A EQ 1 SYSCALL info_myl", 13, 10
                        db "IF A EQ 2 SYSCALL learn_myl", 13, 10
                        db "IF A EQ 3 PRINT ok", 13, 10
                        db "", 13, 10
                        db "EXIT", 13, 10, 0
    iend
    times 4 * file_size db 0

; Команды
cmd_help db "help",0
cmd_shutdown db "shutdown",0
cmd_reboot db "reboot",0
cmd_neofetch db "neofetch",0
cmd_yred db "yred",0
cmd_file db "file",0
cmd_clear db "clear",0
cmd_echo db "echo",0
cmd_goto_echo db "goto-echo",0
cmd_process_sys db "process-sys"
cmd_cd db "cd",0
cmd_mkdir db "mkdir",0
cmd_dir db "dir", 0
cmd_ls db "ls", 0
cmd_logcat db "logcat", 0
cmd_simple_boot db "sb-version", 0
cmd_run db "run",0 


; Команды скриптов
script_print db "PRINT",0
script_wait db "WAIT",0
script_clear db "CLEAR",0
script_exit db "EXIT",0
script_set db "SET",0
script_input db "INPUT",0
script_if db "IF",0

; Операторы IF
op_eq db "EQ",0
op_ne db "NE",0
op_gt db "GT",0
op_lt db "LT",0
op_ge db "GE",0
op_le db "LE",0

; ======== ОСНОВНОЕ ЯДРО ========
kernel_main:
    ; Инициализация сегментов
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0xFFFF

    ; Очистка экрана
    mov ax, 0x0003
    int 0x10

    ; Приветствие
    mov si, welcome_msg
    call print_string

    ; Основной цикл оболочки
shell_loop:
    mov si, prompt
    call print_string
    
    ; Чтение команды
    mov di, command_buffer
    call read_line
    
    ; Обработка команд
    call process_command
    jmp shell_loop

; ======== ОБРАБОТКА КОМАНД ========
process_command:
    ; Проверка пустой команды
    cmp byte [command_buffer], 0
    je .empty
    
    mov si, command_buffer
    mov di, cmd_help
    call strcmp
    je .help
    
    mov si, command_buffer
    mov di, cmd_shutdown
    call strcmp
    je .shutdown
    
    mov si, command_buffer
    mov di, cmd_reboot
    call strcmp
    je .reboot
    
    mov si, command_buffer
    mov di, cmd_neofetch
    call strcmp
    je .neofetch
    
    mov si, command_buffer
    mov di, cmd_yred
    call strcmp
    je .yred
    
    mov si, command_buffer
    mov di, cmd_file
    call strcmp
    je .file

    mov si, command_buffer
    mov di, cmd_clear
    call strcmp
    je .clear

    mov si, command_buffer
    mov di, cmd_dir
    call strcmp
    je .dir
    
    mov si, command_buffer
    mov di, cmd_mkdir
    call strcmp
    je .mkdir

    mov si, command_buffer
    mov di, cmd_cd
    call strcmp
    je .cd

    mov si, command_buffer
    mov di, cmd_process_sys
    call strcmp
    je .processsys

    mov si, command_buffer
    mov di, cmd_ls
    call strcmp
    je .list

    mov si, command_buffer
    mov di, cmd_echo
    call strcmp
    je .echo

    mov si, command_buffer
    mov di, cmd_simple_boot
    call strcmp
    je .sb

    mov si, command_buffer
    mov di, cmd_goto_echo
    call strcmp
    je .gotoecho

    mov si, command_buffer
    mov di, cmd_logcat
    call strcmp
    je .logcat
    
    mov si, command_buffer
    mov di, cmd_run
    call strcmp
    je .run
    
    ; Неизвестная команда
    mov si, unknown_cmd
    call print_string
    ret

.empty:
    ret

.clear:
    mov ax, 0x0003
    int 0x10
    ret

.dir:
    mov si, error_disk
    call print_string
    ret
.mkdir:
    mov si, error_disk
    call print_string
    ret
.cd:
    mov si, error_disk
    call print_string
    ret

.logcat:
    mov si, logcat_msg
    call print_string
    ret

.processsys:
    mov si, process_msg
    call print_string
    ret

.echo:
    mov si, [command_buffer]
    call print_string
    ret
.gotoecho:
    mov si, [command_buffer]
    call print_string
    ret

.sb:
   mov si, sb_msg
   call print_string
   ret

.help:
    mov si, help_msg
    call print_string
    ret


.shutdown:
    ; Попытка выключения через ACPI
    mov ax, 0x5301
    xor bx, bx
    int 0x15
    jc .shutdown_fail
    
    mov ax, 0x530E
    xor bx, bx
    mov cx, 0x102
    int 0x15
    jc .shutdown_fail
    
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15

.shutdown_fail:
    ; Если ACPI не сработал - холодная перезагрузка
    mov ax, 0x0
    out 0x70, al
    mov al, 0x02
    out 0x71, al
    jmp .reboot

.reboot:
    ; Перезагрузка
    mov al, 0xFE
    out 0x64, al
    ret

.neofetch:
    mov si, neofetch_msg
    call print_string
    ret

.yred:
    call text_editor
    ret

.file:
    ; Запрос имени файла
    mov si, file_prompt
    call print_string
    
    ; Чтение имени файла в буфер
    mov di, current_file
    call read_line
    
    ; Проверка пустого имени
    cmp byte [current_file], 0
    je .file_error
    
    ; Поиск файла
    mov si, current_file
    call find_file
    jc .file_not_found
    
    ; Вывод содержимого
    mov si, bx
    call print_string
    mov si, newline
    call print_string
    ret
    
.file_not_found:
    mov si, file_not_found
    call print_string
    ret
    
.file_error:
    mov si, unknown_cmd
    call print_string
    ret

.list:
    ; Вывод списка файлов
    call list_files
    ret

.run:
    ; Запрос имени скрипта
    mov si, run_prompt
    call print_string
    
    ; Чтение имени файла
    mov di, current_file
    call read_line
    
    ; Проверка пустого имени
    cmp byte [current_file], 0
    je .run_error
    
    ; Поиск файла
    mov si, current_file
    call find_file
    jc .file_not_found
    
    ; Запуск скрипта
    call run_script
    ret

.run_error:
    mov si, unknown_cmd
    call print_string
    ret

; ======== ИНТЕРПРЕТАТОР СКРИПТОВ ========
; ======== ИНТЕРПРЕТАТОР СКРИПТОВ ========
run_script:
    ; BX = указатель на начало скрипта
    pusha
    
    ; Сохраняем указатель на скрипт
    mov [.script_ptr], bx
    mov [.original_script], bx
    
    ; Номер текущей строки
    mov word [.line_number], 0
    
    ; Инициализация переменных
    call init_variables
    
.loop:
    ; Увеличиваем номер строки
    inc word [.line_number]
    
    ; Загружаем текущий указатель
    mov si, [.script_ptr]
    
    ; Проверка конца скрипта
    cmp byte [si], 0
    je .end_of_script
    
    ; Чтение строки
    mov di, line_buffer
    call read_script_line
    
    ; Сохраняем новый указатель
    mov [.script_ptr], si
    
    ; Пропуск пустых строк и комментариев
    cmp byte [line_buffer], 0
    je .next_line
    cmp byte [line_buffer], '#'
    je .next_line
    
    ; Разделение команды и аргументов
    call extract_command
    
    ; Обработка команд
    mov si, command_buffer
    mov di, script_print
    call strcmp
    je .do_print
    
    mov si, command_buffer
    mov di, script_wait
    call strcmp
    je .do_wait
    
    mov si, command_buffer
    mov di, script_clear
    call strcmp
    je .do_clear
    
    mov si, command_buffer
    mov di, script_set
    call strcmp
    je .do_set
    
    mov si, command_buffer
    mov di, script_input
    call strcmp
    je .do_input
    
    mov si, command_buffer
    mov di, script_if
    call strcmp
    je .do_if
    
    mov si, command_buffer
    mov di, script_exit
    call strcmp
    je .end_of_script
    
    ; Новые команды
    mov si, command_buffer
    mov di, script_goto
    call strcmp
    je .do_goto
    
    mov si, command_buffer
    mov di, script_syscall
    call strcmp
    je .do_syscall
    
    ; Неизвестная команда
    mov si, script_error
    call print_string
    mov ax, [.line_number]
    call print_number
    mov si, newline
    call print_string
    
    mov si, unknown_script_cmd
    call print_string
    mov si, command_buffer
    call print_string
    mov si, newline
    call print_string

.next_line:
    jmp .loop

.do_print:
    ; Проверка, является ли аргумент переменной
    mov si, .args_buffer
    call is_variable
    jc .print_normal
    
    ; Вывод значения переменной
    mov di, var_value_buffer
    call get_var_value
    mov si, var_value_buffer
    call print_string
    mov si, newline
    call print_string
    jmp .next_line
    
.print_normal:
    ; Вывод обычного текста
    mov si, .args_buffer
    call print_string
    mov si, newline
    call print_string
    jmp .next_line

.do_wait:
    mov si, press_any_key
    call print_string
    mov ah, 0
    int 0x16
    jmp .next_line

.do_clear:
    mov ax, 0x0003
    int 0x10
    jmp .next_line

.do_set:
    ; Установка переменной: SET var value
    ; Извлечь имя переменной
    mov si, .args_buffer
    mov di, var_name_buffer
    call extract_word
    
    ; Извлечь значение
    mov si, .args_buffer
    call skip_word
    mov si, .args_buffer
    mov di, var_value_buffer
    call extract_word
    
    ; Преобразовать значение в число
    mov si, var_value_buffer
    call atoi
    mov [.temp_value], ax
    
    ; Сохранить значение в переменную
    mov si, var_name_buffer
    mov ax, [.temp_value]
    call set_var_value
    jmp .next_line

.do_input:
    ; Ввод значения: INPUT var
    mov si, .args_buffer
    mov di, var_name_buffer
    call extract_word
    
    ; Вывод приглашения
    mov si, input_prompt
    call print_string
    
    ; Чтение значения
    mov di, input_buffer
    call read_line
    
    ; Преобразовать в число
    mov si, input_buffer
    call atoi
    mov [.temp_value], ax
    
    ; Сохранить значение в переменную
    mov si, var_name_buffer
    mov ax, [.temp_value]
    call set_var_value
    jmp .next_line

.do_if:
    ; Формат: IF var1 op var2 command
    ; Извлечь var1
    mov si, .args_buffer
    mov di, var_name_buffer
    call extract_word
    mov si, var_name_buffer
    call get_var_value_num
    mov [.var1_value], ax
    
    ; Извлечь оператор
    mov si, .args_buffer
    call skip_word
    mov si, .args_buffer
    mov di, .operator
    call extract_word
    
    ; Извлечь var2
    mov si, .args_buffer
    call skip_word
    mov si, .args_buffer
    mov di, var_name_buffer
    call extract_word
    mov si, var_name_buffer
    call get_var_value_num
    mov [.var2_value], ax
    
    ; Извлечь команду
    mov si, .args_buffer
    call skip_word
    mov si, .args_buffer
    mov di, .command
    call extract_word
    
    ; Извлечь аргументы команды
    mov si, .args_buffer
    call skip_word
    mov si, .args_buffer
    mov di, .command_args
    call strcpy
    
    ; Проверка условия
    mov si, .operator
    mov di, op_eq
    call strcmp
    je .check_eq
    
    mov si, .operator
    mov di, op_ne
    call strcmp
    je .check_ne
    
    mov si, .operator
    mov di, op_gt
    call strcmp
    je .check_gt
    
    mov si, .operator
    mov di, op_lt
    call strcmp
    je .check_lt
    
    mov si, .operator
    mov di, op_ge
    call strcmp
    je .check_ge
    
    mov si, .operator
    mov di, op_le
    call strcmp
    je .check_le
    
    ; Неизвестный оператор
    jmp .next_line

.check_eq:
    mov ax, [.var1_value]
    cmp ax, [.var2_value]
    je .condition_true
    jmp .next_line

.check_ne:
    mov ax, [.var1_value]
    cmp ax, [.var2_value]
    jne .condition_true
    jmp .next_line

.check_gt:
    mov ax, [.var1_value]
    cmp ax, [.var2_value]
    jg .condition_true
    jmp .next_line

.check_lt:
    mov ax, [.var1_value]
    cmp ax, [.var2_value]
    jl .condition_true
    jmp .next_line

.check_ge:
    mov ax, [.var1_value]
    cmp ax, [.var2_value]
    jge .condition_true
    jmp .next_line

.check_le:
    mov ax, [.var1_value]
    cmp ax, [.var2_value]
    jle .condition_true
    jmp .next_line

.condition_true:
    ; Сохраняем текущее состояние
    push word [.script_ptr]
    push word [.line_number]
    
    ; Выполнить команду
    mov si, .command
    mov di, script_print
    call strcmp
    je .exec_print
    
    ; Добавить другие команды при необходимости
    jmp .condition_done

.exec_print:
    mov si, .command_args
    call print_string
    mov si, newline
    call print_string

.condition_done:
    ; Восстанавливаем состояние
    pop word [.line_number]
    pop word [.script_ptr]
    jmp .next_line

.do_goto:
    ; Формат: GOTO метка
    ; Извлечь имя метки
    mov si, .args_buffer
    mov di, .goto_label
    call extract_word
    
    ; Поиск метки в скрипте
    mov si, [.original_script]  ; Начало скрипта
    mov word [.current_line], 0
    mov [.search_ptr], si

.search_label:
    ; Чтение строки
    mov di, line_buffer
    call read_script_line
    mov [.search_ptr], si
    
    ; Проверка конца скрипта
    cmp byte [line_buffer], 0
    je .label_not_found
    
    ; Проверка, является ли строка меткой
    cmp byte [line_buffer], ':'
    jne .next_search_line
    
    ; Сравнить имя метки
    mov si, line_buffer + 1  ; Пропустить ':'
    mov di, .goto_label
    call strcmp
    je .label_found

.next_search_line:
    jmp .search_label

.label_found:
    ; Установить указатель на следующую строку после метки
    mov si, [.search_ptr]
    mov [.script_ptr], si
    mov word [.line_number], 0  ; Сбросить счетчик строк
    jmp .loop

.label_not_found:
    mov si, label_not_found_msg
    call print_string
    mov si, .goto_label
    call print_string
    mov si, newline
    call print_string
    jmp .next_line

.do_syscall:
    ; Формат: SYSCALL команда
    ; Извлечь имя команды
    mov si, .args_buffer
    mov di, .syscall_cmd
    call extract_word
    
    ; Выполнить системную команду
    mov si, .syscall_cmd
    mov di, syscall_help
    call strcmp
    je .sys_help
    
    mov si, .syscall_cmd
    mov di, syscall_clear
    call strcmp
    je .sys_clear
    
    mov si, .syscall_cmd
    mov di, syscall_neofetch
    call strcmp
    je .sys_neofetch

    mov si, .syscall_cmd
    mov di, syscall_shutdown
    call strcmp
    je .sys_shutdown

    mov si, .syscall_cmd
    mov di, syscall_info_myl
    call strcmp
    je .sys_info_myl

    mov si, .syscall_cmd
    mov di, syscall_learn
    call strcmp
    je .sys_learn_myl
    
    ; Неизвестная системная команда
    mov si, unknown_syscall_msg
    call print_string
    mov si, .syscall_cmd
    call print_string
    mov si, newline
    call print_string
    jmp .next_line

.sys_help:
    mov si, help_msg
    call print_string
    jmp .next_line

.sys_clear:
    mov ax, 0x0003
    int 0x10
    jmp .next_line

.sys_neofetch:
    mov si, neofetch_msg
    call print_string
    jmp .next_line

.sys_shutdown:
    ; Попытка выключения через ACPI
    mov ax, 0x5301
    xor bx, bx
    int 0x15
    
    mov ax, 0x530E
    xor bx, bx
    mov cx, 0x102
    int 0x15
    
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15

.sys_info_myl:
    mov si, info_myl_msg
    call print_string
    jmp .next_line

.sys_learn_myl:
    mov si, learn_myl_msg
    call print_string
    jmp .next_line




.end_of_script:
    mov si, script_end_msg
    call print_string
    popa
    ret

; ... (существующие данные) ...

; Новые данные для интерпретатора
.line_number dw 0
.script_ptr dw 0
.original_script dw 0
.search_ptr dw 0
.current_line dw 0
.args_buffer times 128 db 0
.temp_value dw 0
.var1_value dw 0
.var2_value dw 0
.operator times 8 db 0
.command times 16 db 0
.command_args times 64 db 0
.goto_label times 16 db 0
.syscall_cmd times 16 db 0

; Новые команды скриптов
script_goto db "GOTO",0
script_syscall db "SYSCALL",0

; Системные команды для SYSCALL
syscall_help db "help",0
syscall_clear db "clear",0
syscall_neofetch db "neofetch",0
syscall_shutdown db "shutdown",0
syscall_reboot db "reboot",0
syscall_info_myl db "info_myl", 0
syscall_learn db "learn_myl", 0

; Сообщения
label_not_found_msg db "Label not found: ",0
unknown_syscall_msg db "Unknown SYSCALL command: ",0

; ======== ФУНКЦИЯ ЧТЕНИЯ СТРОКИ СКРИПТА ========
read_script_line:
    push ax
    push cx
    push di
    
    mov cx, 79  ; Максимальная длина строки
    xor al, al
    
.read_char:
    lodsb       ; Загружаем символ из [SI] в AL, увеличиваем SI
    
    ; Проверка конца строки/скрипта
    cmp al, 0
    je .done
    cmp al, 13   ; CR
    je .handle_cr
    cmp al, 10   ; LF
    je .handle_lf
    
    ; Сохраняем символ в буфере
    stosb
    loop .read_char
    jmp .done

.handle_cr:
    ; Пропускаем следующий LF если есть
    cmp byte [si], 10
    jne .done
    inc si      ; Пропускаем LF
    jmp .done

.handle_lf:
    ; Ничего не делаем, просто завершаем строку
    jmp .done

.done:
    ; Завершаем строку нулем
    mov al, 0
    stosb
    
    pop di
    pop cx
    pop ax
    ret

; ======== ФУНКЦИИ РАБОТЫ С ПЕРЕМЕННЫМИ ========
init_variables:
    pusha
    mov cx, 26
    mov di, variables
    xor ax, ax
    rep stosw
    popa
    ret

; Проверить, является ли строка именем переменной
; Вход: SI = строка
; Выход: CF=1 если не переменная, CF=0 если переменная
is_variable:
    pusha
    mov di, var_name_buffer
    call strcpy
    
    ; Проверка длины
    mov si, var_name_buffer
    call strlen
    cmp cx, 1
    jne .not_var
    
    ; Проверка диапазона A-Z
    mov al, [var_name_buffer]
    cmp al, 'A'
    jb .not_var
    cmp al, 'Z'
    ja .not_var
    
    clc
    popa
    ret

.not_var:
    stc
    popa
    ret

; Получить значение переменной как строку
; Вход: SI = имя переменной
; Выход: DI = буфер со значением
get_var_value:
    pusha
    call get_var_value_num
    mov di, var_value_buffer
    call itoa
    popa
    mov di, var_value_buffer
    ret

; Получить числовое значение переменной
; Вход: SI = имя переменной
; Выход: AX = значение
get_var_value_num:
    push bx
    mov al, [si]
    sub al, 'A'
    mov bl, 2
    mul bl
    mov bx, ax
    mov ax, [variables + bx]
    pop bx
    ret

; Установить значение переменной
; Вход: SI = имя переменной, AX = значение
set_var_value:
    push bx
    mov bl, [si]
    sub bl, 'A'
    movzx bx, bl
    shl bx, 1
    mov [variables + bx], ax
    pop bx
    ret

; ======== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ========
; Чтение строки из скрипта

.check_lf:
    cmp byte [si], 10
    jne .exit
    inc si
    
.exit:
    popa
    ret

; Извлечь команду и аргументы
extract_command:
    pusha
    mov si, line_buffer
    mov di, command_buffer
    mov cx, 64
    
    ; Копируем команду до первого пробела
.copy_cmd:
    lodsb
    cmp al, ' '
    je .space_found
    cmp al, 0
    je .end_of_line
    stosb
    loop .copy_cmd
    jmp .end_of_line

.space_found:
    ; Завершаем команду
    mov al, 0
    stosb
    
    ; Копируем аргументы в буфер
    mov di, run_script.args_buffer
.copy_args:
    lodsb
    cmp al, 0
    je .end_of_line
    stosb
    jmp .copy_args

.end_of_line:
    mov al, 0
    stosb
    popa
    ret

; Извлечь слово (до пробела)
; Вход: SI = исходная строка, DI = буфер назначения
extract_word:
    pusha
    ; Пропустить пробелы
.skip_spaces:
    lodsb
    cmp al, ' '
    je .skip_spaces
    cmp al, 0
    je .done
    
    ; Копировать слово
.copy_word:
    stosb
    lodsb
    cmp al, ' '
    je .space_found
    cmp al, 0
    je .done
    jmp .copy_word

.space_found:
    mov al, 0
    stosb
    dec si ; Возвращаемся к пробелу
    jmp .done

.done:
    mov al, 0
    stosb
    popa
    ret

; Пропустить слово
; Вход: SI = строка
skip_word:
    pusha
.skip_spaces:
    lodsb
    cmp al, ' '
    je .skip_spaces
    cmp al, 0
    je .done
    
    ; Пропустить слово
.skip_char:
    lodsb
    cmp al, ' '
    je .done
    cmp al, 0
    je .done
    jmp .skip_char

.done:
    dec si
    popa
    ret

; Преобразовать строку в число
; Вход: SI = строка
; Выход: AX = число
atoi:
    push bx
    push cx
    push dx
    push si
    xor ax, ax
    xor cx, cx
    mov bx, 10
    
.convert_loop:
    lodsb
    test al, al
    jz .done
    cmp al, '0'
    jb .done
    cmp al, '9'
    ja .done
    sub al, '0'
    mov cl, al
    mul bx
    add ax, cx
    jmp .convert_loop
    
.done:
    pop si
    pop dx
    pop cx
    pop bx
    ret

; Преобразовать число в строку
; Вход: AX = число, DI = буфер назначения
itoa:
    pusha
    mov bx, 10
    xor cx, cx
    test ax, ax
    jnz .convert
    mov al, '0'
    stosb
    jmp .done
    
.convert:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz .convert
    
.store:
    pop ax
    add al, '0'
    stosb
    loop .store

.done:
    mov al, 0
    stosb
    popa
    ret

; Длина строки
; Вход: SI = строка
; Выход: CX = длина
strlen:
    push si
    xor cx, cx
.loop:
    lodsb
    test al, al
    jz .done
    inc cx
    jmp .loop
.done:
    pop si
    ret

; ... (остальные функции: list_files, text_editor, save_to_filesystem, find_file, 
; print_string, read_line, strcmp, strcpy) ...

; Пример реализации strcpy для полноты


list_files:
    mov si, list_header
    call print_string
    
    mov cx, 5
    mov bx, files
    xor dx, dx  ; Счетчик файлов
    
.list_loop:
    ; Проверка, занят ли слот
    cmp byte [bx], 0
    je .next_file
    
    ; Увеличиваем счетчик файлов
    inc dx
    
    ; Вывод префикса
    mov si, list_entry
    call print_string
    
    ; Вывод имени файла
    mov si, bx
    call print_string
    
    ; Перенос строки
    mov si, newline
    call print_string

.next_file:
    add bx, file_size
    loop .list_loop
    
    ; Проверка, найдены ли файлы
    cmp dx, 0
    jne .done
    
    ; Если файлов нет
    mov si, list_empty
    call print_string
    
.done:
    ret

; ======== ТЕКСТОВЫЙ РЕДАКТОР ========
text_editor:
    ; Очистка буфера
    mov di, file_buffer
    mov cx, 256
    xor al, al
    rep stosb
    
    mov si, editing_msg
    call print_string
    
    mov di, file_buffer
    mov cx, 0          ; Счетчик символов
    
.edit_loop:
    ; Чтение клавиши
    mov ah, 0
    int 0x16
    
    ; ESC - сохранение
    cmp ah, 0x01
    je .save_file
    
    ; Backspace
    cmp ah, 0x0E
    je .backspace
    
    ; Enter
    cmp al, 0x0D
    je .newline
    
    ; Проверка на переполнение
    cmp cx, 254
    jge .edit_loop
    
    ; Вывод символа
    mov ah, 0x0E
    int 0x10
    
    ; Сохранение в буфер
    stosb
    inc cx
    jmp .edit_loop

.backspace:
    cmp cx, 0
    jle .edit_loop
    dec di
    dec cx
    mov byte [di], 0
    
    ; Удаление на экране
    mov ah, 0x0E
    mov al, 8
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 8
    int 0x10
    jmp .edit_loop

.newline:
    mov ah, 0x0E
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10
    
    mov al, 13
    stosb
    inc cx
    mov al, 10
    stosb
    inc cx
    jmp .edit_loop

.save_file:
    ; Запрос имени файла
    mov si, file_prompt
    call print_string
    
    mov di, current_file
    call read_line
    
    ; Сохранение в ФС
    call save_to_filesystem
    
    ; Сообщение об успехе
    mov si, file_saved_msg
    call print_string
    ret

; ======== ФУНКЦИИ ФАЙЛОВОЙ СИСТЕМЫ ========
save_to_filesystem:
    ; Поиск свободного слота
    mov cx, 5
    mov bx, files
.next_slot:
    cmp byte [bx], 0
    je .found_slot
    add bx, file_size
    loop .next_slot
    ; Если не нашли - перезаписываем первый
    mov bx, files

.found_slot:
    ; Копирование имени
    mov si, current_file
    mov di, bx
    call strcpy
    
    ; Копирование содержимого
    mov si, file_buffer
    add di, file.content
    call strcpy
    ret

find_file:
    ; SI = имя файла
    mov cx, 5
    mov bx, files
.search_loop:
    push si
    push bx
    mov di, bx
    call strcmp
    pop bx
    pop si
    je .found
    
    add bx, file_size
    loop .search_loop
    stc ; файл не найден
    ret

.found:
    ; BX указывает на структуру файла
    lea si, [bx + file.content]
    mov bx, si
    clc ; файл найден
    ret

; ======== СЛУЖЕБНЫЕ ФУНКЦИИ ========
print_number:
    pusha
    mov cx, 0
    mov bx, 10

print_string:
    pusha
    mov ah, 0x0E
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    popa
    ret

read_line:
    pusha
    xor cx, cx
    mov byte [di], 0
.read_char:
    mov ah, 0
    int 0x16
    
    cmp al, 0x0D       ; Enter
    je .done
    
    cmp ah, 0x0E       ; Backspace
    je .backspace
    
    cmp ah, 0x01       ; ESC
    je .done
    
    cmp cx, 63
    jge .read_char
    
    stosb
    inc cx
    
    mov ah, 0x0E
    int 0x10
    jmp .read_char

.backspace:
    cmp cx, 0
    je .read_char
    dec di
    dec cx
    mov byte [di], 0
    
    mov ah, 0x0E
    mov al, 8
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 8
    int 0x10
    jmp .read_char

.done:
    mov al, 0
    stosb
    
    mov ah, 0x0E
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10
    popa
    ret

strcmp:
    pusha
.loop:
    mov al, [si]
    cmp al, [di]
    jne .not_equal
    test al, al
    jz .equal
    inc si
    inc di
    jmp .loop

.equal:
    popa
    xor ax, ax
    ret

.not_equal:
    popa
    mov ax, 1
    ret

strcpy:
    pusha
.loop:
    lodsb
    stosb
    test al, al
    jnz .loop
    popa
    ret
