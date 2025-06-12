[org 0x1000]
[bits 16]

jmp kernel_main

; Константы
%define MAX_FILES 10
%define FILE_NAME_SIZE 16
%define FILE_CONTENT_SIZE 1024
%define FILE_SIZE FILE_NAME_SIZE + FILE_CONTENT_SIZE
%define MAX_FUNCS 20
%define FUNC_NAME_SIZE 16
%define MAX_STACK_DEPTH 20
%define COMMAND_BUF_SIZE 64
%define TICKS_PER_SECOND 18     ; 18.2 тика в секунду

; Данные ядра
welcome_msg db "YodaOS 16-bit v1.3", 13, 10, 0
prompt db "YodaOS> ", 0
newline db 13, 10, 0
unknown_cmd db "Unknown command", 13, 10, 0
help_msg db "Commands: help, shutdown, reboot, neofetch, yred, file, ls, run, logcat, sb-version, cd, dir, mkdir, process-sys", 13, 10, 0
file_not_found db "File not found", 13, 10, 0
file_prompt db "Enter filename: ", 0
editing_msg db "Text Editor (ESC=save, BACKSPACE=delete):", 13, 10, 0
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
func_declared db "Function declared: ",0
func_not_found db "Function not found: ",0
importing_msg db "Importing: ",0
runcode_msg db "Executing: ",0
stack_overflow db "Stack overflow!",13,10,0
max_depth_msg db "Maximum depth reached",13,10,0
return_msg db "Returning from function",13,10,0
endfunc_msg db "ENDFUNC found, exiting function definition",13,10,0
fs_full_msg db "File system full",13,10,0
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
    db "This MYL script language in YodaOS", 0x0D, 0x0A
    db "create by Yoda", 0x0D, 0x0A, 0
learn_myl_msg:
    db "learn yscr language, lets start)", 0x0D, 0x0A
    db "PRINT <var or text> - print text or var on screen", 0x0D, 0x0A
    db "SET <var> 0 - set value <var> 0   "  
    db "INPUT <var> - enter value in var", 0x0D, 0x0A
    db "CLEAR - clear you screen   "
    db "WAIT - wait you type on keyboard", 0x0D, 0x0A
    db "FUNC <name> - create a function", 0x0D, 0x0A
    db "ENDFUNC - end FUNC", 0x0D, 0x0A
    db "RUNCODE <filename> - run file", 0x0D, 0x0A
    db "IMPORT <filename> - import FUNC in filename", 0x0D, 0x0A
    db "TIME <sec> - set timer on <sec>", 0x0D, 0x0A
    db "PRINTTIME <Text> - super slow print text on screen", 0x0D, 0x0A
    db "TYPE <text> - slow print text on screen", 0x0D, 0x0A
    db "RANDOM - print random number 10-99", 0x0D, 0x0A
    db "IF <var> <operator> <other var or number> <action> <func> - check var > var2, var < var2, var = var2.  ", 0x0D, 0x0A
    db "IF operators:", 0x0D, 0x0A
    db "EQ - var1 = var2  "
    db "GT - var1 > var2  "
    db "LT - var2 > var1",0x0D, 0x0A
    db "SYSCALL - call system command example SYSCALL neofetch", 0x0D, 0x0A
    db "GOTO <cycle name> - infinity cycle, example code:", 0x0D, 0x0A
    db "GOTO label", 0x0D, 0x0A
    db "PRINT test code", 0x0D, 0x0A
    db ":label", 0x0D, 0x0A
    db "EXIT", 0x0D, 0x0A
    db "EXIT - end script file", 0x0D, 0x0A, 0
sb_msg db "sb version: 1.0", 13, 10 , 0
time_msg db "TIME: Waiting ",0
seconds_msg db " seconds",13,10,0
random_msg db "Random number: ",0
type_msg db "TYPE: ",0


; Буферы
current_file: times FILE_NAME_SIZE db 0
command_buffer: times COMMAND_BUF_SIZE db 0
file_buffer: times FILE_CONTENT_SIZE db 0
line_buffer: times 80 db 0
input_buffer: times 64 db 0
var_name_buffer: times 16 db 0
func_name_buf: times FUNC_NAME_SIZE db 0
import_buf: times FILE_NAME_SIZE db 0
temp_str: times 16 db 0

; Переменные (A-Z)
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

; Файловая система
files: times MAX_FILES * FILE_SIZE db 0

; Таблица функций
func_names: times MAX_FUNCS * FUNC_NAME_SIZE db 0
func_starts: times MAX_FUNCS dw 0
func_ends: times MAX_FUNCS dw 0
func_count db 0

; Стек вызовов
call_stack: times MAX_STACK_DEPTH * 4 db 0
stack_ptr dw call_stack

; Команды оболочки
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
cmd_learn db "learn-yscr", 0

; Команды скриптов
script_print db "PRINT",0
script_wait db "WAIT",0
script_clear db "CLEAR",0
script_exit db "EXIT",0
script_set db "SET",0
script_input db "INPUT",0
script_if db "IF",0
script_func db "FUNC",0
script_endfunc db "ENDFUNC",0
script_call db "CALL",0
script_return db "RETURN",0
script_import db "IMPORT",0
script_runcode db "RUNCODE",0
script_time db "TIME",0
script_random db "RANDOM",0
script_type db "TYPE",0
script_printtime db "PRINTTIME",0

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
    mov di, cmd_learn
    call strcmp
    je .learn
    
    mov si, command_buffer
    mov di, cmd_run
    call strcmp
    je .run
    
    mov si, unknown_cmd
    call print_string
    ret

.empty:
    ret
.learn:
   mov si, learn_myl_msg
   call print_string
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
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15
    ret

.reboot:
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
    mov si, file_prompt
    call print_string
    mov di, current_file
    call read_line
    cmp byte [current_file], 0
    je .file_error
    mov si, current_file
    call find_file
    jc .file_not_found
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
    ret

.list:
    call list_files
    ret

.run:
    mov si, run_prompt
    call print_string
    mov di, current_file
    call read_line
    cmp byte [current_file], 0
    je .run_error
    mov si, current_file
    call find_file
    jc .file_not_found
    call run_script
    ret
.run_error:
    ret

; ======== ИНТЕРПРЕТАТОР СКРИПТОВ ========
run_script:
    pusha
    mov [.script_ptr], bx
    mov word [.line_number], 0
    mov byte [.skip_depth], 0
    mov byte [.in_function], 0
    call init_variables

.script_loop:
    ; Проверка на конец файла
    mov si, [.script_ptr]
    cmp byte [si], 0
    je .end_script
    
    ; Проверка глубины пропуска
    cmp byte [.skip_depth], 0
    je .execute_mode
    
    ; Режим пропуска (объявление функции)
    mov di, line_buffer
    call read_script_line
    mov [.script_ptr], si
    
    cmp byte [line_buffer], 0
    je .next_line
    
    call extract_command
    
    ; Проверка на FUNC (вложенные функции)
    mov si, command_buffer
    mov di, script_func
    call strcmp
    je .skip_func_found
    
    ; Проверка на ENDFUNC
    mov si, command_buffer
    mov di, script_endfunc
    call strcmp
    je .skip_endfunc_found
    
    jmp .next_line

.skip_func_found:
    inc byte [.skip_depth]
    jmp .next_line

.skip_endfunc_found:
    dec byte [.skip_depth]
    jnz .next_line
    
    ; Сохранение конца функции
    mov al, [func_count]
    dec al
    mov bl, 2
    mul bl
    mov si, ax
    mov ax, [.script_ptr]
    mov [func_ends + si], ax
    
    mov si, endfunc_msg
    call print_string
    jmp .next_line

.execute_mode:
    ; Чтение строки
    mov di, line_buffer
    call read_script_line
    mov [.script_ptr], si
    
    cmp byte [line_buffer], 0
    je .next_line
    
    inc word [.line_number]
    
    call extract_command
    
    ; Обработка команд
    mov si, command_buffer
    mov di, script_func
    call strcmp
    je .do_func
    
    mov si, command_buffer
    mov di, script_call
    call strcmp
    je .do_call
    
    mov si, command_buffer
    mov di, script_return
    call strcmp
    je .do_return
    
    mov si, command_buffer
    mov di, script_endfunc
    call strcmp
    je .do_endfunc
    
    mov si, command_buffer
    mov di, script_import
    call strcmp
    je .do_import
    
    mov si, command_buffer
    mov di, script_runcode
    call strcmp
    je .do_runcode
    
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
    mov di, script_exit
    call strcmp
    je .end_script

     mov si, command_buffer
    mov di, script_time
    call strcmp
    je .do_time
    
    mov si, command_buffer
    mov di, script_random
    call strcmp
    je .do_random
    
    mov si, command_buffer
    mov di, script_type
    call strcmp
    je .do_type
    
    mov si, command_buffer
    mov di, script_printtime
    call strcmp
    je .do_printtime
    
    jmp .next_line

.next_line:
    jmp .script_loop

.do_print:
    mov si, args_buffer
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
    mov si, args_buffer
    mov di, var_name_buffer
    call extract_word
    mov al, [var_name_buffer]
    cmp al, 'A'
    jb .set_error
    cmp al, 'Z'
    ja .set_error
    
    mov si, args_buffer
    call skip_word
    call skip_spaces
    call atoi
    mov bx, variables
    sub al, 'A'
    movzx di, al
    shl di, 1
    mov [bx+di], ax
    jmp .next_line

.set_error:
    jmp .next_line

.do_input:
    mov si, args_buffer
    mov di, var_name_buffer
    call extract_word
    mov al, [var_name_buffer]
    cmp al, 'A'
    jb .input_error
    cmp al, 'Z'
    ja .input_error
    
    mov si, input_prompt
    call print_string
    
    mov di, input_buffer
    call read_line
    
    mov si, input_buffer
    call atoi
    mov bx, variables
    sub byte [var_name_buffer], 'A'
    movzx di, byte [var_name_buffer]
    shl di, 1
    mov [bx+di], ax
    jmp .next_line

.input_error:
    jmp .next_line

.do_func:
    mov al, [func_count]
    cmp al, MAX_FUNCS
    jge .func_table_full
    
    ; Извлечение имени функции
    mov si, args_buffer
    mov di, func_name_buf
    call extract_word
    
    ; Проверка существования
    call find_function
    jnc .skip_adding
    
    ; Сохранение имени
    movzx ax, byte [func_count]
    mov di, FUNC_NAME_SIZE
    mul di
    mov di, func_names
    add di, ax
    mov si, func_name_buf
    call strcpy
    
    ; Сохранение начального адреса
    movzx si, byte [func_count]
    shl si, 1
    mov ax, [.script_ptr]
    mov [func_starts + si], ax
    
    mov byte [.skip_depth], 1
    mov si, func_declared
    call print_string
    mov si, func_name_buf
    call print_string
    mov si, newline
    call print_string
    
    inc byte [func_count]
    jmp .next_line

.skip_adding:
    mov byte [.skip_depth], 1
    jmp .next_line

.do_call:
    mov si, args_buffer
    mov di, func_name_buf
    call extract_word
    
    call find_function
    jc .func_not_found
    
    ; Проверка глубины стека
    mov ax, [stack_ptr]
    cmp ax, call_stack + MAX_STACK_DEPTH * 4
    jae .stack_overflow
    
    ; Сохранение контекста
    mov di, [stack_ptr]
    mov ax, [.script_ptr]
    mov [di], ax
    mov ax, [.line_number]
    mov [di+2], ax
    add word [stack_ptr], 4
    
    ; Установка нового указателя
    movzx si, bl
    shl si, 1
    mov ax, [func_starts + si]
    mov [.script_ptr], ax
    mov word [.line_number], 0
    
    jmp .script_loop

.do_return:
    mov ax, [stack_ptr]
    cmp ax, call_stack
    jle .stack_empty
    
    sub word [stack_ptr], 4
    mov si, [stack_ptr]
    mov ax, [si+2]
    mov [.line_number], ax
    mov ax, [si]
    mov [.script_ptr], ax
    
    mov si, return_msg
    call print_string
    jmp .next_line

.do_endfunc:
    ; ENDFUNC во время выполнения = возврат
    jmp .do_return

.do_import:
    mov si, args_buffer
    mov di, import_buf
    call extract_word
    
    mov si, import_buf
    call find_file
    jc .import_error
    
    mov si, importing_msg
    call print_string
    mov si, import_buf
    call print_string
    mov si, newline
    call print_string
    
    mov si, bx
    call parse_functions
    jmp .next_line

.do_runcode:
    mov si, args_buffer
    mov di, import_buf
    call extract_word
    
    mov si, import_buf
    call find_file
    jc .import_error
    
    ; Проверка глубины стека
    mov ax, [stack_ptr]
    cmp ax, call_stack + MAX_STACK_DEPTH * 4
    jae .stack_overflow
    
    ; Сохранение контекста
    mov di, [stack_ptr]
    mov ax, [.script_ptr]
    mov [di], ax
    mov ax, [.line_number]
    mov [di+2], ax
    add word [stack_ptr], 4
    
    ; Установка нового скрипта
    mov [.script_ptr], bx
    mov word [.line_number], 0
    
    mov si, runcode_msg
    call print_string
    mov si, import_buf
    call print_string
    mov si, newline
    call print_string
    
    jmp .script_loop

.do_time:
    mov si, time_msg
    call print_string
    
    mov si, args_buffer
    call atoi       ; Получаем секунды в AX
    
    ; Выводим количество секунд
    call itoa
    mov si, temp_str
    call print_string
    mov si, seconds_msg
    call print_string
    
    ; Преобразуем секунды в тики (18.2 тика/сек)
    mov bx, TICKS_PER_SECOND
    mul bx          ; AX = секунды * TICKS_PER_SECOND
    
    ; Вызываем функцию ожидания
    call wait_ticks
    
    jmp .next_line

.do_random:
    ; Генерируем случайное число от 10 до 99
    call generate_random
    mov [var_R], ax
    
    mov si, random_msg
    call print_string
    
    ; Преобразуем число в строку и выводим
    mov ax, [var_R]
    call itoa
    mov si, temp_str
    call print_string
    mov si, newline
    call print_string
    
    jmp .next_line

.do_type:
    mov si, type_msg
    call print_string
    
    mov si, args_buffer
    mov ax, 1      ; Задержка 1 тик (~55 мс)
    call type_effect
    
    jmp .next_line

.do_printtime:
    mov si, args_buffer
    mov ax, 9      ; Задержка 9 тиков (~0.5 сек)
    call type_effect
    
    jmp .next_line

.end_script:
    mov si, script_end_msg
    call print_string
    popa
    ret

.stack_overflow:
    mov si, stack_overflow
    call print_string
    jmp .end_script

.func_table_full:
    mov si, max_depth_msg
    call print_string
    jmp .next_line

.func_not_found:
    mov si, func_not_found
    call print_string
    mov si, func_name_buf
    call print_string
    mov si, newline
    call print_string
    jmp .next_line

.import_error:
    mov si, file_not_found
    call print_string
    jmp .next_line

.stack_empty:
    jmp .end_script

; Данные интерпретатора
.line_number dw 0
.script_ptr dw 0
.skip_depth db 0
.in_function db 0
args_buffer times COMMAND_BUF_SIZE db 0

; ======== СИСТЕМНЫЕ ФУНКЦИИ ========
; Генерация случайного числа от 10 до 99
generate_random:
    push cx
    push dx
    
    ; Используем системный таймер для генерации случайного числа
    mov ah, 0x00
    int 0x1A        ; Получаем тики в CX:DX
    
    ; Используем младшие биты для генерации числа
    mov ax, dx      ; Используем младшую часть
    and ax, 0x00FF  ; Берем младший байт
    
    ; Масштабируем до диапазона 0-89
    xor dx, dx
    mov cx, 90
    div cx          ; DX = остаток от 0 до 89
    
    ; Добавляем 10 для получения диапазона 10-99
    add dx, 10
    mov ax, dx
    
    pop dx
    pop cx
    ret

; Ожидание указанного количества тиков
; Вход: AX - количество тиков для ожидания
wait_ticks:
    pusha
    mov [.ticks], ax
    
    ; Получаем текущее время
    mov ah, 0x00
    int 0x1A        ; CX:DX = текущее время в тиках
    mov [.start_low], dx
    mov [.start_high], cx
    
    ; Вычисляем время окончания
    add dx, [.ticks]
    adc cx, 0
    mov [.end_low], dx
    mov [.end_high], cx
    
.wait_loop:
    ; Получаем текущее время
    mov ah, 0x00
    int 0x1A        ; CX:DX = текущее время
    
    ; Сравниваем с временем окончания
    cmp cx, [.end_high]
    jb .wait_loop   ; Младше - продолжаем ждать
    ja .done        ; Старше - выходим
    
    ; Старшие слова равны, сравниваем младшие
    cmp dx, [.end_low]
    jb .wait_loop
    
.done:
    popa
    ret
.ticks dw 0
.start_low dw 0
.start_high dw 0
.end_low dw 0
.end_high dw 0

; Эффект печати с задержкой
; Вход: SI - строка, AX - количество тиков задержки на символ
type_effect:
    pusha
    mov [.delay_ticks], ax
    
    ; Сохраняем позицию курсора
    mov ah, 0x03
    xor bh, bh
    int 0x10
    mov [.cursor_pos], dx
    
.next_char:
    lodsb
    test al, al
    jz .done
    
    ; Пропускаем управляющие символы
    cmp al, 13 ; CR
    je .next_char
    cmp al, 10 ; LF
    je .next_char
    
    ; Выводим символ
    mov ah, 0x0E
    xor bh, bh
    int 0x10
    
    ; Задержка
    mov ax, [.delay_ticks]
    call wait_ticks
    
    jmp .next_char
    
.done:
    ; Переводим строку после завершения
    mov si, newline
    call print_string
    popa
    ret
.delay_ticks dw 0
.cursor_pos dw 0

; Преобразование числа в строку
; Вход: AX - число
; Выход: temp_str - строка с числом
itoa:
    pusha
    mov di, temp_str
    mov cx, 0
    mov bx, 10
    
    ; Обрабатываем ноль отдельно
    test ax, ax
    jnz .convert
    mov byte [di], '0'
    inc di
    jmp .done
    
.convert:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz .convert
    
.store:
    pop ax
    stosb
    loop .store
    
.done:
    mov byte [di], 0 ; Завершающий ноль
    popa
    ret

init_variables:
    pusha
    mov cx, 26
    mov di, variables
    xor ax, ax
    rep stosw
    popa
    ret

find_function:
    push cx
    push si
    push di
    mov cl, [func_count]
    test cl, cl
    jz .not_found
    
    xor bx, bx   ; Индекс функции
    mov di, func_name_buf

.search_loop:
    ; Вычисление позиции имени
    mov ax, bx
    mov si, FUNC_NAME_SIZE
    mul si
    mov si, func_names
    add si, ax
    
    ; Сравнение строк
    push bx
    push di
    call strcmp
    pop di
    pop bx
    je .found
    
    inc bx
    dec cl
    jnz .search_loop

.not_found:
    stc
    pop di
    pop si
    pop cx
    ret

.found:
    clc
    pop di
    pop si
    pop cx
    ret

parse_functions:
    pusha
    mov [.file_ptr], si
    mov byte [.skip_depth], 0
    
.parse_loop:
    mov si, [.file_ptr]
    cmp byte [si], 0
    je .done
    
    mov di, line_buffer
    call read_script_line
    mov [.file_ptr], si
    
    cmp byte [line_buffer], 0
    je .parse_loop
    
    call extract_command
    
    cmp byte [.skip_depth], 0
    je .not_skipping
    
    ; Режим пропуска
    mov si, command_buffer
    mov di, script_func
    call strcmp
    je .skip_func
    
    mov si, command_buffer
    mov di, script_endfunc
    call strcmp
    je .skip_endfunc
    
    jmp .parse_loop

.not_skipping:
    mov si, command_buffer
    mov di, script_func
    call strcmp
    jne .parse_loop
    
    ; Проверка свободного места
    mov al, [func_count]
    cmp al, MAX_FUNCS
    jge .done
    
    ; Извлечение имени
    mov si, args_buffer
    mov di, func_name_buf
    call extract_word
    
    ; Проверка существования
    call find_function
    jnc .parse_loop
    
    ; Сохранение имени
    movzx ax, byte [func_count]
    mov di, FUNC_NAME_SIZE
    mul di
    mov di, func_names
    add di, ax
    mov si, func_name_buf
    call strcpy
    
    ; Сохранение начального адреса
    movzx si, byte [func_count]
    shl si, 1
    mov ax, [.file_ptr]
    mov [func_starts + si], ax
    
    mov byte [.skip_depth], 1
    inc byte [func_count]
    jmp .parse_loop

.skip_func:
    inc byte [.skip_depth]
    jmp .parse_loop

.skip_endfunc:
    dec byte [.skip_depth]
    jnz .parse_loop
    
    ; Сохранение конца функции
    mov al, [func_count]
    dec al
    mov bl, 2
    mul bl
    mov si, ax
    mov ax, [.file_ptr]
    mov [func_ends + si], ax
    jmp .parse_loop

.done:
    popa
    ret

.file_ptr dw 0
.skip_depth db 0

; ======== ФУНКЦИИ ФАЙЛОВОЙ СИСТЕМЫ ========
list_files:
    mov si, list_header
    call print_string
    mov cx, MAX_FILES
    mov bx, files
    xor dx, dx
.list_loop:
    cmp byte [bx], 0
    je .next_file
    inc dx
    mov si, list_entry
    call print_string
    mov si, bx
    call print_string
    mov si, newline
    call print_string
.next_file:
    add bx, FILE_SIZE
    loop .list_loop
    cmp dx, 0
    jne .done
    mov si, list_empty
    call print_string
.done:
    ret

find_file:
    mov cx, MAX_FILES
    mov bx, files
.search_loop:
    push si
    push bx
    mov di, bx
    call strcmp
    pop bx
    pop si
    je .found
    add bx, FILE_SIZE
    loop .search_loop
    stc
    ret
.found:
    lea si, [bx + FILE_NAME_SIZE] ; Содержимое файла
    mov bx, si
    clc
    ret

save_to_filesystem:
    mov cx, MAX_FILES
    mov bx, files
.next_slot:
    cmp byte [bx], 0
    je .found_slot
    add bx, FILE_SIZE
    loop .next_slot
    mov si, fs_full_msg
    call print_string
    stc
    ret
.found_slot:
    mov si, current_file
    mov di, bx
    call strcpy
    mov si, file_buffer
    add di, FILE_NAME_SIZE
    call strcpy
    clc
    ret

; ======== ТЕКСТОВЫЙ РЕДАКТОР ========
text_editor:
    mov di, file_buffer
    mov cx, FILE_CONTENT_SIZE
    xor al, al
    rep stosb
    
    mov si, editing_msg
    call print_string
    
    mov di, file_buffer
    mov cx, 0
    
.edit_loop:
    mov ah, 0
    int 0x16
    
    cmp ah, 0x01   ; ESC
    je .save_file
    
    cmp ah, 0x0E   ; Backspace
    je .backspace
    
    cmp al, 0x0D   ; Enter
    je .newline
    
    cmp cx, FILE_CONTENT_SIZE - 1
    jge .edit_loop
    
    mov ah, 0x0E
    int 0x10
    
    stosb
    inc cx
    jmp .edit_loop

.backspace:
    cmp cx, 0
    jle .edit_loop
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
    mov si, file_prompt
    call print_string
    mov di, current_file
    call read_line
    cmp byte [current_file], 0
    je .skip_save
    call save_to_filesystem
    jc .save_error
    mov si, file_saved_msg
    call print_string
    ret
.skip_save:
    ret
.save_error:
    ret

; ======== СЛУЖЕБНЫЕ ФУНКЦИИ ========
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
    cmp al, 0x0D
    je .done
    cmp ah, 0x0E
    je .backspace
    cmp cx, COMMAND_BUF_SIZE-1
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

extract_word:
    pusha
.skip_spaces:
    lodsb
    cmp al, ' '
    je .skip_spaces
    cmp al, 0
    je .done
.copy:
    stosb
    lodsb
    cmp al, ' '
    je .space
    cmp al, 0
    je .done
    jmp .copy
.space:
    mov al, 0
    stosb
.done:
    mov al, 0
    stosb
    popa
    ret

skip_word:
    pusha
.skip_spaces:
    lodsb
    cmp al, ' '
    je .skip_spaces
    cmp al, 0
    je .done
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

read_script_line:
    push ax
    push cx
    push di
    mov cx, 79
.read_char:
    lodsb
    cmp al, 0
    je .done
    cmp al, 13
    je .handle_cr
    cmp al, 10
    je .handle_lf
    stosb
    loop .read_char
    jmp .done
.handle_cr:
    cmp byte [si], 10
    jne .done
    inc si
    jmp .done
.handle_lf:
    jmp .done
.done:
    mov al, 0
    stosb
    pop di
    pop cx
    pop ax
    ret

extract_command:
    pusha
    mov si, line_buffer
    mov di, command_buffer
    mov cx, COMMAND_BUF_SIZE
.copy_cmd:
    lodsb
    cmp al, ' '
    je .space
    cmp al, 0
    je .done
    stosb
    loop .copy_cmd
    jmp .done
.space:
    mov al, 0
    stosb
    mov di, args_buffer
.copy_args:
    lodsb
    cmp al, 0
    je .done
    stosb
    jmp .copy_args
.done:
    mov al, 0
    stosb
    popa
    ret

atoi:
    push bx
    push cx
    push dx
    xor ax, ax
    xor cx, cx
    mov bx, 10
.next_digit:
    lodsb
    test al, al
    jz .done
    cmp al, '0'
    jb .done
    cmp al, '9'
    ja .done
    sub al, '0'
    xchg ax, cx
    mul bx
    add ax, cx
    xchg ax, cx
    jmp .next_digit
.done:
    mov ax, cx
    pop dx
    pop cx
    pop bx
    ret

skip_spaces:
    lodsb
    cmp al, ' '
    je skip_spaces
    dec si
    ret

times 0x5000 - ($-$$) db 0
